-- Creo volumen temporal, mido, creo índices y vuelvo al seed original.
INSERT INTO users (email, username, created_at, updated_at)
SELECT 'bulk_user_' || n || '@example.com', 'bulk_user_' || n,
       TIMESTAMPTZ '2025-01-01 00:00+00' + (n || ' seconds')::interval,
       TIMESTAMPTZ '2025-01-01 00:00+00' + (n || ' seconds')::interval
FROM generate_series(1, 500) n;

INSERT INTO posts (title, slug, content, status, published_at, author_id, category_id, created_at, updated_at)
SELECT 'bulk-post-' || n, 'bulk-post-' || n, 'Bulk deterministic content',
       CASE WHEN n % 20 = 0 THEN 'draft' ELSE 'published' END,
       CASE WHEN n % 20 = 0 THEN NULL ELSE TIMESTAMPTZ '2025-01-01 00:00+00' + (n || ' minutes')::interval END,
       13 + ((n - 1) % 500), ((n - 1) % 5) + 1,
       TIMESTAMPTZ '2025-01-01 00:00+00', TIMESTAMPTZ '2025-01-01 00:00+00'
FROM generate_series(1, 20000) n;

INSERT INTO comments (content, post_id, user_id, created_at)
SELECT 'bulk-comment-' || n, 33 + ((n - 1) % 20000), 13 + ((n - 1) % 500),
       TIMESTAMPTZ '2025-02-01 00:00+00' + (n || ' seconds')::interval
FROM generate_series(1, 200000) n;

INSERT INTO post_tags (post_id, tag_id)
SELECT 33 + ((n - 1) % 20000), ((n - 1) % 11) + 1 FROM generate_series(1, 40000) n
ON CONFLICT DO NOTHING;

VACUUM ANALYZE;

-- [I02] ANTES: en la referencia observo Seq Scan y filas descartadas por el filtro.
EXPLAIN ANALYZE SELECT id, user_id, content FROM comments WHERE post_id = 1;
CREATE INDEX idx_comments_post_id ON comments(post_id);
-- [I02] DESPUÉS: Bitmap Index Scan on idx_comments_post_id.
EXPLAIN ANALYZE SELECT id, user_id, content FROM comments WHERE post_id = 1;

EXPLAIN ANALYZE SELECT id, title FROM posts WHERE author_id = 13;
CREATE INDEX idx_posts_author_id ON posts(author_id);
-- Después: Bitmap Index Scan on idx_posts_author_id.
EXPLAIN ANALYZE SELECT id, title FROM posts WHERE author_id = 13;

EXPLAIN ANALYZE SELECT post_id FROM post_tags WHERE tag_id = 3;
CREATE INDEX idx_post_tags_tag_id ON post_tags(tag_id);
-- Después: Bitmap Index Scan on idx_post_tags_tag_id.
EXPLAIN ANALYZE SELECT post_id FROM post_tags WHERE tag_id = 3;

BEGIN;
EXPLAIN ANALYZE DELETE FROM users WHERE username LIKE 'bulk_user_%' AND id < 113;
ROLLBACK;
CREATE INDEX idx_comments_user_id ON comments(user_id);
BEGIN;
-- Después: la comprobación de la FK usa idx_comments_user_id y reduce el tiempo del trigger.
EXPLAIN ANALYZE DELETE FROM users WHERE username LIKE 'bulk_user_%' AND id < 113;
ROLLBACK;

EXPLAIN ANALYZE SELECT id, title FROM posts WHERE status = 'published' ORDER BY published_at DESC LIMIT 10;
CREATE INDEX idx_posts_status_published_at ON posts(status, published_at DESC);
-- Después: Index Scan, sin Sort separado.
EXPLAIN ANALYZE SELECT id, title FROM posts WHERE status = 'published' ORDER BY published_at DESC LIMIT 10;

EXPLAIN ANALYZE SELECT id, title FROM posts WHERE status = 'draft' ORDER BY updated_at DESC LIMIT 10;
CREATE INDEX idx_posts_drafts_updated_at ON posts(updated_at DESC) WHERE status = 'draft';
EXPLAIN ANALYZE SELECT id, title FROM posts WHERE status = 'draft' ORDER BY updated_at DESC LIMIT 10;

DELETE FROM users WHERE username LIKE 'bulk_user_%';
VACUUM ANALYZE;

