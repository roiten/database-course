USE `news_feed`;

-- 1
SELECT news_id, name
FROM news_item
WHERE is_published = 1;

-- 2
SELECT image
FROM image_block ib
         JOIN news_block ON ib.block_id = news_block.block_id
WHERE news_id = 1
LIMIT 1;

-- 3
SELECT DISTINCT `ip_address`
FROM news_view;

# OUTER JOIN разобраться

-- 4
SELECT news_item.news_id,
       news_item.name,
       author.name,
       position,
       text,
       image
FROM news_item
         INNER JOIN author ON news_item.author_id = author.author_id
         INNER JOIN news_block ON news_item.news_id = news_block.news_id
         LEFT JOIN text_block ON news_block.block_id = text_block.block_id
         LEFT JOIN image_block ON news_block.block_id = image_block.block_id
WHERE news_item.news_id = 1;

-- 5
SELECT news_item.news_id, name, COUNT(*) AS sum_views
FROM news_item
         JOIN news_feed.news_view nv ON news_item.news_id = nv.news_id
GROUP BY news_item.news_id, news_item.name
ORDER BY sum_views DESC
LIMIT 5;

-- 6
SELECT DISTINCT news_item.news_id, name, view_time
FROM news_item
         JOIN news_view ON news_view.news_id = news_item.news_id
WHERE news_view.view_time > '2026-05-13';

-- 7
SELECT news_item.news_id, news_item.name, COUNT(news_block.block_id) AS content_amount
FROM news_item
    JOIN news_block ON news_item.news_id = news_block.news_id
GROUP BY news_item.news_id
ORDER BY content_amount DESC
LIMIT 5;

-- 8
SELECT news_item.news_id, news_item.name, COUNT(comment.comment_id) AS comment_ammount
FROM news_item
    JOIN comment ON news_item.news_id = comment.news_id
GROUP BY news_item.news_id
ORDER BY comment_ammount DESC
LIMIT 5;

-- 9
SELECT DATE(view_time) AS view_date, COUNT(*) AS views_ammount
FROM news_view
GROUP BY view_date
ORDER BY views_ammount DESC;

-- 10
SELECT news_item.news_id, name, text
FROM news_item
         JOIN news_block ON news_item.news_id = news_block.news_id
         JOIN text_block ON news_block.block_id = text_block.block_id
WHERE name LIKE '%но%'
   OR text LIKE '%но%';

-- 11
WITH RECURSIVE comment_tree AS (
    SELECT comment_id,
           parent_id,
           comment_id AS root,
           1 AS depth
    FROM comment
    WHERE parent_id IS NULL

    UNION ALL

    SELECT c.comment_id,
           c.parent_id,
           ct.root,
           ct.depth + 1
    FROM comment c
             JOIN comment_tree ct
                  ON c.parent_id = ct.comment_id
)

SELECT root AS comment_id,
       MAX(depth) AS max_depth
FROM comment_tree
GROUP BY root
ORDER BY max_depth DESC;
-- 12
SELECT news_item.thread_id, SUM(size_bytes) AS size
FROM news_item
         LEFT JOIN thread ON news_item.thread_id = thread.title
         JOIN news_block ON news_item.news_id = news_block.news_id
         JOIN video_block ON news_block.block_id = video_block.block_id
GROUP BY news_item.thread_id
HAVING size > 220000
ORDER BY size;

