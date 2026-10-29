SET TIME ZONE 'UTC';
\pset null '(null)'

-- [Q01] Posts publicados con su autor.
SELECT p.id, p.title, u.username, p.published_at
FROM posts p INNER JOIN users u ON u.id = p.author_id
WHERE p.status = 'published' ORDER BY p.published_at DESC;

-- [Q11] Cantidad de posts por usuario, incluidos los que tienen cero.
SELECT u.id, u.username, count(p.id) AS post_count
FROM users u LEFT JOIN posts p ON p.author_id = u.id
GROUP BY u.id, u.username ORDER BY post_count DESC, u.username;

-- [Q04] Posts con sus tags a través de la tabla puente.
SELECT p.id, p.title, t.name AS tag
FROM posts p JOIN post_tags pt ON pt.post_id = p.id JOIN tags t ON t.id = pt.tag_id
ORDER BY p.id, t.name;

-- [Q15] Los cinco autores con más posts.
SELECT u.username, count(p.id) AS post_count
FROM users u JOIN posts p ON p.author_id = u.id
GROUP BY u.id, u.username ORDER BY post_count DESC, u.username LIMIT 5;

-- [Q18] Promedio de comentarios por post publicado, incluyendo los que tienen cero.
SELECT round(avg(comment_count), 2) AS average_comments
FROM (SELECT p.id, count(c.id) AS comment_count FROM posts p LEFT JOIN comments c ON c.post_id = p.id WHERE p.status = 'published' GROUP BY p.id) q;

-- [Q17] Tags más usados, incluyendo los que tienen cero.
SELECT t.name, count(pt.post_id) AS use_count
FROM tags t LEFT JOIN post_tags pt ON pt.tag_id = t.id
GROUP BY t.id, t.name ORDER BY use_count DESC, t.name;

-- [Q19] Posts con más comentarios que el promedio.
SELECT p.id, p.title, count(c.id) AS comments
FROM posts p LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id, p.title
HAVING count(c.id) > (SELECT avg(n) FROM (SELECT count(*) AS n FROM comments GROUP BY post_id) counts)
ORDER BY comments DESC, p.id;

-- [Q24] Dashboard por usuario mediante CTEs.
WITH post_counts AS (SELECT author_id AS user_id, count(*) AS posts, max(created_at) AS last_post FROM posts GROUP BY author_id),
comment_counts AS (SELECT user_id, count(*) AS comments, max(created_at) AS last_comment FROM comments GROUP BY user_id)
SELECT u.username, coalesce(p.posts, 0) AS posts, coalesce(c.comments, 0) AS comments,
       greatest(p.last_post, c.last_comment) AS last_activity
FROM users u LEFT JOIN post_counts p ON p.user_id = u.id LEFT JOIN comment_counts c ON c.user_id = u.id
ORDER BY u.username;

-- [Q25] Publicados en los últimos 30 días del seed con autor y cantidad de comentarios.
SELECT p.id, p.title, u.username, count(c.id) AS comments
FROM posts p JOIN users u ON u.id = p.author_id LEFT JOIN comments c ON c.post_id = p.id
WHERE p.status = 'published' AND p.published_at >= TIMESTAMPTZ '2026-02-01 00:00+00'
GROUP BY p.id, p.title, u.username, p.published_at ORDER BY p.published_at DESC;

-- [Q26] Resumen completo con autor, categoría, comentarios y tags.
SELECT p.id, p.title, u.username AS author, cat.name AS category,
       count(DISTINCT c.id) AS comments,
       coalesce(string_agg(DISTINCT t.name, ', ' ORDER BY t.name), '') AS tags
FROM posts p JOIN users u ON u.id = p.author_id
LEFT JOIN categories cat ON cat.id = p.category_id
LEFT JOIN comments c ON c.post_id = p.id
LEFT JOIN post_tags pt ON pt.post_id = p.id LEFT JOIN tags t ON t.id = pt.tag_id
GROUP BY p.id, p.title, u.username, cat.name ORDER BY p.id;

