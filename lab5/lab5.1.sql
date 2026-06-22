DROP DATABASE IF EXISTS `path`;
CREATE DATABASE IF NOT EXISTS `path`;

USE path;

CREATE TABLE directories
(
    `id`   INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL
);

CREATE TABLE directory_closure
(
    parent_id   INT NOT NULL,
    child_id INT NOT NULL,
    depth         INT NOT NULL DEFAULT 0,
    PRIMARY KEY (parent_id, child_id),
    FOREIGN KEY (parent_id) REFERENCES directories (id) ON DELETE CASCADE,
    FOREIGN KEY (child_id) REFERENCES directories (id) ON DELETE CASCADE
);

INSERT INTO directories (name)
VALUES ('home'),           -- /home
       ('init'),           -- /init
       ('lib'),            -- /lib
       ('media'),          -- /media
       ('mnt'),            -- /mnt
       ('opt'),            -- /opt
       ('sys'),            -- /sys
       ('var'),            -- /var
       ('roiten'),         -- /roiten
       ('institute'),      -- /roiten/institute
       ('comb-algorithm'), -- /roiten/institute/comb-algorithm
       ('lab2'),           -- /roiten/institute/comb-algorithm/lab2
       ('lab3'),           -- /roiten/institute/comb-algorithm/lab3
       ('lab4'),           -- /roiten/institute/comb-algorithm/lab4
       ('src'),            -- /roiten/institute/comb-algorithm/lab4/src
       ('tests'),          -- /roiten/institute/comb-algorithm/lab4/tests
       ('oop'),            -- /roiten/institute/oop
       ('lab2'),           -- /roiten/institute/oop/lab2
       ('lab4'); -- /roiten/institute/oop/lab4

INSERT INTO directory_closure (child_id, parent_id, depth)
VALUES (1, 1, 0),
       (2, 2, 0),
       (3, 3, 0),
       (4, 4, 0),
       (5, 5, 0),
       (6, 6, 0),
       (7, 7, 0),
       (8, 8, 0),
       (9, 1, 1),
       (9, 9, 0),
       (10, 1, 2),
       (10, 9, 1),
       (10, 10, 0),
       (11, 1, 3),
       (11, 9, 2),
       (11, 10, 1),
       (11, 11, 0),
       (12, 1, 4),
       (12, 9, 3),
       (12, 10, 2),
       (12, 11, 1),
       (12, 12, 0),
       (13, 1, 4),
       (13, 9, 3),
       (13, 10, 2),
       (13, 11, 1),
       (13, 13, 0),
       (14, 1, 4),
       (14, 9, 3),
       (14, 10, 2),
       (14, 11, 1),
       (14, 14, 0),
       (15, 1, 5),
       (15, 9, 4),
       (15, 10, 3),
       (15, 11, 2),
       (15, 14, 1),
       (15, 15, 0),
       (16, 1, 5),
       (16, 9, 4),
       (16, 10, 3),
       (16, 11, 2),
       (16, 14, 1),
       (16, 16, 0),
       (17, 1, 3),
       (17, 9, 2),
       (17, 10, 1),
       (17, 17, 0),
       (18, 1, 4),
       (18, 9, 3),
       (18, 10, 2),
       (18, 17, 1),
       (18, 18, 0),
       (19, 1, 4),
       (19, 9, 3),
       (19, 10, 2),
       (19, 17, 1),
       (19, 19, 0);


SELECT id
FROM directories
WHERE name = 'lab4';

SELECT * FROM directory_closure;

-- перемещение
# DELETE FROM directory_closure
# WHERE child_id IN (
#     SELECT dc.parent_id
#         FROM directory_closure dc
#         WHERE dc.parent_id = 14
# );
# попробовать одной транзакцией в три запроса


# DELETE dc
# FROM directory_closure dc
# INNER JOIN directory_closure subtree ON dc.child_id = subtree.child_id AND subtree.parent_id= 14
# INNER JOIN directory_closure old_parents ON dc.parent_id = old_parents.parent_id
# WHERE old_parents.child_id = 14 AND old_parents.parent_id != 14;
#
# INSERT INTO directory_closure (child_id, parent_id, depth)
# SELECT dc_node.child_id, dc_p.parent_id, dc_node.depth + dc_p.depth + 1
# FROM directory_closure dc_node, directory_closure dc_p
# WHERE dc_node.parent_id = 14
#   AND dc_p.child_id = 17;

# DROP TEMPORARY TABLE IF EXISTS to_delete;
#
# CREATE TEMPORARY TABLE to_delete AS (
#     SELECT dc.child_id, dc.parent_id, dc.depth
#     FROM directory_closure dc
#     WHERE dc.parent_id = 14
# );
#
# DELETE FROM directory_closure dc
# WHERE child_id IN (SELECT to_delete.child_id FROM to_delete)
#   AND dc.parent_id NOT IN (SELECT to_delete.child_id FROM to_delete);
BEGIN;
CREATE TEMPORARY TABLE to_delete AS (
    SELECT dc.child_id, dc.parent_id, dc.depth
    FROM directory_closure dc
    WHERE dc.parent_id = 14
);

SELECT GROUP_CONCAT(child_id) INTO @ids FROM to_delete;

DELETE FROM directory_closure
WHERE FIND_IN_SET(child_id, @ids)
  AND NOT FIND_IN_SET(parent_id, @ids);

INSERT INTO directory_closure (parent_id, child_id, depth)
SELECT
    p.parent_id,
    td.child_id,
    p.depth + td.depth + 1 AS depth
FROM to_delete td
CROSS JOIN (
    SELECT parent_id, depth
    FROM directory_closure
    WHERE child_id = 17
) AS p;

DROP TEMPORARY TABLE IF EXISTS to_delete;
COMMIT;

-- извечение поддерева
SELECT dir.id, dir.name, c.depth
FROM directory_closure c
    JOIN directories dir ON dir.id = c.child_id
WHERE c.parent_id = 11
ORDER BY c.depth, dir.id;

-- поиск листа
# SELECT d.id, d.name
# FROM directories d
#          JOIN directory_closure c ON d.id = c.child_id
#          JOIN directories anc ON anc.id = c.parent_id
# WHERE d.name = 'tests'
#   AND anc.name = 'institute'
#   AND NOT EXISTS (SELECT 1
#                   FROM directory_closure dc
#                   WHERE dc.depth > 0
#                     AND dc.parent_id = d.id);
-- подзапросы замедляют работу

SELECT d.id, d.name
FROM directories d
LEFT JOIN directory_closure dc ON d.id = dc.parent_id AND dc.depth > 0
WHERE dc.parent_id IS NULL
AND d.name = 'tests';


-- вывод списка всех соседних директорий
SELECT dc2.child_id, d.name
FROM directory_closure dc
INNER JOIN directory_closure dc2 ON dc.parent_id = dc2.parent_id AND dc2.depth = 1
INNER JOIN directories d
           ON dc2.child_id = d.id
               AND dc.depth = 1
               AND dc.child_id = 17;

-- вставки 3 элементов
INSERT INTO directories (name)
VALUES ('lab5');
SET @lab = LAST_INSERT_ID();
SET @parent = (SELECT id FROM directories WHERE name = 'oop');

INSERT INTO directory_closure (child_id, parent_id, depth)
SELECT @lab, parent_id, depth + 1
FROM directory_closure
WHERE child_id = @parent
UNION
SELECT @lab, @lab, 0;

INSERT INTO directories (name)
VALUES ('lab6');
SET @lab = LAST_INSERT_ID();
SET @parent = (SELECT id FROM directories WHERE name = 'oop');

INSERT INTO directory_closure (child_id, parent_id, depth)
SELECT @lab, parent_id, depth + 1
FROM directory_closure
WHERE child_id = @parent
UNION
SELECT @lab, @lab, 0;

INSERT INTO directories (name)
VALUES ('lab7');
SET @lab = LAST_INSERT_ID();
SET @parent = (SELECT id FROM directories WHERE name = 'oop');

INSERT INTO directory_closure (child_id, parent_id, depth)
SELECT @lab, parent_id, depth + 1
FROM directory_closure
WHERE child_id = @parent
UNION
SELECT @lab, @lab, 0;


-- удаление поддерева
DELETE FROM directories WHERE id = 17;

SELECT child_id
FROM directory_closure
WHERE parent_id = 17;

SELECT parent_id
FROM directory_closure
WHERE child_id = 17;

SELECT id, name
FROM directories
WHERE id = 17;


-- удаление элементов
DELETE FROM directories WHERE id IN (2, 3);
DELETE FROM directories WHERE name = 'opt';
