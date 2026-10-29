-- Datos deterministas: siempre obtengo los mismos casos y el mismo orden.
SET TIME ZONE 'UTC';

INSERT INTO users (email, username, role, is_active, created_at, updated_at) VALUES
('ana@example.com','ana_garcia','admin',true,'2026-01-01 10:00+00','2026-01-01 10:00+00'),
('ben@example.com','ben_carter','editor',true,'2026-01-02 10:00+00','2026-01-02 10:00+00'),
('chloe@example.com','chloe_kim','editor',true,'2026-01-03 10:00+00','2026-01-03 10:00+00'),
('diego@example.com','diego_ruiz','user',true,'2026-01-04 10:00+00','2026-01-04 10:00+00'),
('emma@example.com','emma_wilson','user',true,'2026-01-05 10:00+00','2026-01-05 10:00+00'),
('farid@example.com','farid_khan','user',true,'2026-01-06 10:00+00','2026-01-06 10:00+00'),
('giulia@example.com','giulia_rossi','user',true,'2026-01-07 10:00+00','2026-01-07 10:00+00'),
('hugo@example.com','hugo_silva','user',true,'2026-01-08 10:00+00','2026-01-08 10:00+00'),
('ines@example.com','ines_martin','user',true,'2026-01-09 10:00+00','2026-01-09 10:00+00'),
('joel@example.com','joel_smith','user',true,'2026-01-10 10:00+00','2026-01-10 10:00+00'),
('kai@example.com','kai_tanaka','user',true,'2026-01-11 10:00+00','2026-01-11 10:00+00'),
('lena@example.com','lena_novak','user',false,'2026-01-12 10:00+00','2026-01-12 10:00+00');

INSERT INTO categories (name, slug, description, created_at) VALUES
('Backend','backend','APIs y servicios','2026-01-01 11:00+00'),
('Python','python','Lenguaje y ecosistema','2026-01-01 11:01+00'),
('Databases','databases','Persistencia y SQL','2026-01-01 11:02+00'),
('DevOps','devops','Operación y despliegue','2026-01-01 11:03+00'),
('Career','career','Carrera profesional','2026-01-01 11:04+00'),
('Security','security','Categoría sin uso para probar LEFT JOIN','2026-01-01 11:05+00');

INSERT INTO tags (name, slug, created_at) VALUES
('Python','python','2026-01-01 12:00+00'),('FastAPI','fastapi','2026-01-01 12:01+00'),
('PostgreSQL','postgresql','2026-01-01 12:02+00'),('SQL','sql','2026-01-01 12:03+00'),
('Async','async','2026-01-01 12:04+00'),('API','api','2026-01-01 12:05+00'),
('Testing','testing','2026-01-01 12:06+00'),('Docker','docker','2026-01-01 12:07+00'),
('Career','career','2026-01-01 12:08+00'),('Performance','performance','2026-01-01 12:09+00'),
('Architecture','architecture','2026-01-01 12:10+00'),('GraphQL','graphql','2026-01-01 12:11+00');

INSERT INTO posts (title, slug, content, excerpt, status, published_at, author_id, category_id, created_at, updated_at)
SELECT
    'Pulse article ' || n,
    'pulse-article-' || n,
    'Deterministic content for article ' || n || '. I use it to verify joins, aggregates and pagination.',
    'Excerpt for article ' || n,
    CASE WHEN n >= 28 THEN 'draft' ELSE 'published' END,
    CASE WHEN n >= 28 THEN NULL ELSE TIMESTAMPTZ '2026-02-01 09:00+00' + (n || ' days')::interval END,
    ((n - 1) % 10) + 1,
    CASE WHEN n IN (10, 30) THEN NULL ELSE ((n - 1) % 5) + 1 END,
    TIMESTAMPTZ '2026-01-01 09:00+00' + (n || ' days')::interval,
    TIMESTAMPTZ '2026-01-01 09:00+00' + (n || ' days')::interval
FROM generate_series(1, 32) AS n;

-- Solo los posts 1 a 29 reciben tags: el 30 queda como caso borde sin tags.
INSERT INTO post_tags (post_id, tag_id)
SELECT ((n - 1) % 29) + 1, ((n * 5) % 11) + 1
FROM generate_series(1, 61) AS n;

-- Los posts 25 y 26 no reciben comentarios; kai_tanaka sí comenta y no publica.
INSERT INTO comments (content, post_id, user_id, created_at)
SELECT
    'Deterministic comment ' || n,
    ((n - 1) % 24) + 1,
    ((n - 1) % 11) + 1,
    TIMESTAMPTZ '2026-03-01 12:00+00' + (n || ' hours')::interval
FROM generate_series(1, 58) AS n;

