# Заполните Базу Данных данными, можете посмотреть задание 1.3 для более глубокого понимания того, что требуется в базе данных. Требования к запросам:
# Запрос создаёт правильный результат без неожиданных потерь данных
# Соблюдены правила форматирования
# Каждая сущность должна иметь как минимум 2 запроса на модификацию (UPDATE) одного или нескольких полей.
# Как минимум 3 запроса должны быть идемпотентными `INSERT ON DUPLICATE KEY IGNORE`
# Как минимум 3 запроса должны быть готовы к тому, что сущность в БД уже есть `INSERT ON DUPLICATE KEY UPDATE`
# Как минимум 6 операций должны быть в транзакции (3 с COMMIT и 3 с ROLLBACK), выбирайте операции осознанно, с проверкой результата перед коммитом
#
# За реализацию обратных запросов для 3-х сущностей + 5 баллов
#
# Если запрос на изменение данных переводит БД из состояния A в состояние B, то обратный запрос должен переводить из состояния B в состояние A и не более того. Другими словами, гибкость в обратном запросе не нужна. Обратный запрос может содержать конкретные данные, то есть захардкоженные значения, полученные заранее SELECT-запросами.
# Допускается заполнение не всей БД, а только той части, которая будет обязательна для выполнения запросов из задания 1.3, за неполноту заполненности данных баллы будут снижаться.

# author, comment, image_block, news_block, news_item, news_view, text_block, thread, video_block

USE `news_feed`;

INSERT INTO author (author_id, name, email, bio)
VALUES (1,
        'Иван Иванов',
        'ivan.ivanov@gmail.com',
        '')
ON DUPLICATE KEY UPDATE `email` = VALUES(`email`);


BEGIN;
INSERT IGNORE INTO `author` (author_id, name, email, bio, avatar, gender)
VALUES (2,
        'Рик Эстли',
        'RickAstley@yahoo.com',
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        UNHEX(0x48656C6C6F20424C4F42),
        'male');
SELECT *
FROM author;
COMMIT;

UPDATE `author`
SET `is_active` = 1
WHERE author_id = 1;

UPDATE `author`
SET `is_active` = 0
WHERE author_id = 1;

UPDATE `author`
SET `last_login` = NOW()
WHERE author_id = 2;

INSERT INTO `news_item` (name, author_id)
VALUES ('Я заполнил первую новость',
        1);

INSERT INTO `news_item` (news_id, name, author_id)
VALUES (1, 'Я обновил первую новость', 1)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`);

BEGIN;
SELECT *
FROM `news_item`
WHERE author_id = 1;

DELETE
FROM `news_item`
WHERE author_id = 1
  AND name = 'Я обновил первую новость';

SELECT *
FROM `news_item`
WHERE author_id = 1;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE `news_item`;
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;

INSERT INTO news_item (name, author_id, thread_id)
VALUES ('Я заполнил первую новость заново',
        1, 'yellow');

INSERT INTO news_item (name, author_id)
VALUES ('Портал позволяет добавить вторую новость=)', 2);

UPDATE news_item
SET is_published=1
WHERE news_id = 1;

UPDATE news_item
SET author_id=1
WHERE news_id = 2;

INSERT INTO `news_block` (`block_id`, `news_id`, `position`)
VALUES (UUID_TO_BIN(UUID()), 1, 1),
       (UUID_TO_BIN(UUID()), 1, 2);


INSERT INTO `text_block` (`block_id`, `text`)
SELECT block_id, 'Текст тестового блока'
FROM `news_block`
WHERE `news_id` = 1
  AND `position` = 1;

INSERT INTO `image_block` (`block_id`, `image`)
SELECT block_id, UNHEX('FAFAFAFAFAFAFAFAFF')
FROM `news_block`
WHERE `news_id` = 1
  AND `position` = 2;


SET @news2_block_pos1 = UUID_TO_BIN(UUID());
SET @news2_block_pos2 = UUID_TO_BIN(UUID());
SET @news2_block_pos3 = UUID_TO_BIN(UUID());

INSERT INTO `news_block` (block_id, news_id, position)
VALUES (@news2_block_pos1, 2, 1),
       (@news2_block_pos2, 2, 2),
       (@news2_block_pos3, 2, 3);

INSERT INTO `text_block`
VALUES (@news2_block_pos1, 'Немного текста тут'),
       (@news2_block_pos3, 'поменьше здесь');

UPDATE `text_block`
SET `text`='поменьше здесь (ред)'
WHERE `block_id` = @news2_block_pos1;

UPDATE `text_block`
SET `text`='текст'
WHERE `text` = 'Текст тестового блока';

INSERT INTO `image_block`
VALUES (@news2_block_pos2, UNHEX('123456789ABCDEF'));

UPDATE `image_block`
SET image=UNHEX('8989898989898')
WHERE block_id = @news2_block_pos2;

UPDATE `image_block`
SET image = 0x123ABCDF0000000EDD
WHERE image = 0xFAFAFAFAFAFAFAFAFF;

SET @video_block_id = UUID_TO_BIN(UUID());
INSERT INTO news_block (block_id, news_id, position)
VALUES (@video_block_id, 1, 4);

INSERT INTO `video_block` (block_id, video_url, size_bytes)
VALUES (@video_block_id, '/media/test1.mov', 5242880);

UPDATE `video_block`
SET `video_url`  = '/media/test1.avi',
    `size_bytes` = 6000000
WHERE `block_id` = @video_block_id;

UPDATE `video_block`
SET `video_url`  = '/media/test1[cropped].avi',
    `size_bytes` = 2000100
WHERE block_id = @video_block_id;

UPDATE `news_block`
SET position=0
WHERE (news_id = 2 AND position = 1);

UPDATE `news_block`
SET position=1
WHERE (news_id = 2 AND position = 3);

UPDATE `news_block`
SET position=3
WHERE (news_id = 2 AND position = 0);

SELECT *
FROM `news_block`
WHERE news_id = 2;

COMMIT;

BEGIN;
SET @first_text_block_id = (SELECT `block_id`
                            FROM `news_block`
                            WHERE `news_id` = 1
                              AND `position` = 1);

REPLACE `news_block` (block_id, news_id, position)
VALUES (@first_text_block_id, 1, 10);

SELECT *
FROM `news_block`
WHERE news_id = 1;
SELECT *
FROM `text_block`
WHERE block_id = @first_text_block_id;

ROLLBACK;

UPDATE IGNORE `news_item`
SET `is_published` = 1
WHERE news_id IN (1, 2);

UPDATE IGNORE `news_item`
SET `is_published` = 0
WHERE news_id IN (1, 2);

UPDATE IGNORE `news_item`
SET `is_published` = 1
WHERE news_id IN (1, 2);

INSERT IGNORE INTO `news_view` (news_id, ip_address)
VALUES (1, '188.145.23.2'),
       (1, '123.145.167.8'),
       (1, '2001:0db8:85a3:0000:0000:8a2e:0370:7334');

INSERT IGNORE INTO `news_view` (news_id, ip_address)
VALUES (2, '1.1.3.2'),
       (2, '192.168.1.7'),
       (2, '1000:0bd2:83a2:0000:0000:8a2e:0370:7334');

UPDATE `news_view`
SET `ip_address` = '89.105.200.65'
WHERE ip_address = '1.1.3.2'
  AND `news_id` = 2;

UPDATE `news_view`
SET `ip_address` = '1.1.3.2'
WHERE ip_address = '89.105.200.65'
  AND `news_id` = 2;

UPDATE `news_view`
SET `view_time` = NOW()
WHERE ip_address = '123.145.167.8'
  AND `news_id` = 1;

DELETE
FROM `news_view`
WHERE ip_address = '123.145.167.8';

INSERT INTO `comment` (news_id, ip_address, text)
VALUES (1, '123.145.167.8', 'ого! первая новость!');

INSERT INTO `comment` (news_id, ip_address, text, parent_id)
VALUES (1, '188.145.23.2', 'ого! первый комментарий!', 1);

UPDATE `comment`
SET `text`='чуть подредактированный комментарий=)'
WHERE `news_id` = 1
  AND `ip_address` = '188.145.23.2';

UPDATE `comment`
SET `text`='ого! первый комментарий!'
WHERE `news_id` = 1
  AND `ip_address` = '188.145.23.2';

UPDATE `comment`
SET `is_deleted`=1
WHERE news_id = 1
  AND `text` = 'ого! первая новость!';

INSERT INTO `comment` (news_id, ip_address, text, parent_id)
VALUES (1, '123.145.167.8', 'ого! первый ответ к комментарию:)', 2);

BEGIN;
INSERT INTO `comment` (news_id, ip_address, text, parent_id)
VALUES (1, '15.98.33.11', 'сломалось чутка всё...', 1);

SELECT is_deleted
FROM comment
WHERE comment_id = 1;

SELECT *
FROM `comment`
WHERE ip_address = '15.98.33.11'
  AND news_id = 1;

ROLLBACK;

INSERT INTO `thread` (thread_id, title, description, created_by)
VALUES ('red', 'Красная ветка', 'Важные новости', 1),
       ('yellow', 'Жёлтая пресса', 'Слухи и домыслы', 1);

INSERT INTO `thread` (thread_id, title, description, created_by)
VALUES ('yellow', 'Желтющая пресса', 'шокирующая информация от очевидцев', 1)
ON DUPLICATE KEY UPDATE `title`       = VALUES(`title`),
                        `description` = VALUES(`description`),
                        `created_by`  = VALUES(`created_by`);

UPDATE `thread`
SET title='Жёлтая пресса',
    description='Слухи и домыслы'
WHERE thread_id = 'yellow';

UPDATE `thread`
SET `created_by` = 2
WHERE thread_id = 'red';

UPDATE `thread`
SET `created_by` = 1
WHERE thread_id = 'red';

BEGIN;
SELECT COUNT(*)
FROM news_item
WHERE `author_id` = 1;

DELETE
FROM comment
WHERE news_id IN (SELECT news_id FROM news_item WHERE author_id = 1);

DELETE
FROM author
WHERE author_id = 1;

SELECT COUNT(*)
FROM author;

SELECT COUNT(*)
FROM news_item
WHERE `author_id` = 1;

ROLLBACK;

BEGIN;
SELECT COUNT(*)
FROM news_item
WHERE `author_id` = 1;

SELECT COUNT(*)
FROM news_item
WHERE `author_id` = 2;

UPDATE `news_item`
SET `author_id` = 2
WHERE (`author_id` = 1 AND `is_published` = 1);

SELECT COUNT(*)
FROM news_item
WHERE `author_id` = 1;

SELECT COUNT(*)
FROM news_item
WHERE `author_id` = 2;
ROLLBACK;


INSERT INTO author (name, email, bio, avatar, gender)
VALUES ('Dmitriy', 'd0per@yandex.ru', 'message not priority', 0x12141190302302, 'male'),
       ('Mikhail', 'mikhail@gmail.com', 'message not priority', 0x00000000000001, 'male'),
       ('Andrew', 'apasniytacher@gmail.com', 'message not priority', 0x12141190302302, 'male'),
       ('Anonimous', 'anonimuos@temp.mail', 'message not priority', 0x12141190302302, 'male'),
       ('Ivan Petrov', '', 'message not priority', 0x12141190302302, 'male');


INSERT INTO news_item (name, author_id, thread_id, is_published)
VALUES ('Крыса ворвалась в прямой эфир телеканала в Британии', 3, 'yellow', 0),
       ('National Geographic показали новые фото природы', 4, 'red', 0),
       ('Чеснок оказался стимулятором для крыс', 5, 'red', 0),
       ('Из магазинов пропал сыр-косичка', 6, 'yellow', 0),
       ('Новая новость', 7, 'red', 0);

SET @block1_t = UUID();
SET @block1_i = UUID();

SET @block2_t = UUID();
SET @block2_i = UUID();

SET @block3_t = UUID();
SET @block3_i = UUID();

SET @block4_t = UUID();
SET @block4_i = UUID();

SET @block5_v = UUID();

INSERT INTO news_block (block_id, news_id, position)
VALUES (UUID_TO_BIN(@block1_i), 3, 1),
       (UUID_TO_BIN(@block1_t), 3, 2),

       (UUID_TO_BIN(@block2_i), 4, 1),
       (UUID_TO_BIN(@block2_t), 4, 2),

       (UUID_TO_BIN(@block3_i), 5, 1),
       (UUID_TO_BIN(@block3_t), 5, 2),

       (UUID_TO_BIN(@block4_i), 6, 1),
       (UUID_TO_BIN(@block4_t), 6, 2),

       (UUID_TO_BIN(@block5_v), 7, 1);

INSERT INTO image_block (block_id, image)
VALUES (UUID_TO_BIN(@block1_i), 0xABCDEF1123451FF),
       (UUID_TO_BIN(@block2_i), 0x32D4321EF11552FF),
       (UUID_TO_BIN(@block3_i), 0xCDDDD0F11234533FF),
       (UUID_TO_BIN(@block4_i), 0xBBCDEF11234544FF);

INSERT INTO text_block (block_id, text)
VALUES (UUID_TO_BIN(@block1_t),
        'Крыса ворвалась в прямой эфир, пробежала по столу и скрылась. Операторв в попытках заснять происходящее уронил камеру со штативом, случайно задев её ногой'),
       (UUID_TO_BIN(@block2_t), 'Их вы можете найти в интернете! Делитесь что вы думаете о снимках в комментариях!'),
       (UUID_TO_BIN(@block3_t),
        'Да-да, это чистая правда, но есть нюансы! К таким выводам пришли британские исследователи!'),
       (UUID_TO_BIN(@block4_t),
        'По информации одного из наших корреспондентов, он усиленно пытался найти сыр косичку на прилавках магазинов, но тщетно:(');

INSERT INTO video_block (block_id, video_url, size_bytes)
VALUES (UUID_TO_BIN(@block5_v), 'https://youtu.be/ya-vezgaju-v-stroiku', 191243821);

UPDATE news_item
SET is_published=1
WHERE news_id IN (3, 4, 5, 6);

INSERT IGNORE INTO news_view (news_id, ip_address)
VALUES (3, '12.23.43.6'),
       (3, '11.12.13.14'),
       (3, '15.1.1.1'),
       (3, '15.1.1.2'),
       (3, '15.1.1.3'),
       (3, '15.1.1.51'),

       (4, '78.11.34.5'),
       (5, '78.11.34.7'),
       (6, '32.77.62.8'),
       (6, '78.11.34.5');


INSERT INTO comment (news_id, ip_address, text, is_deleted)
VALUES (3, '12.23.43.6', 'аххахахахах', 0),
       (3, '12.32.42.12', 'улыбнуло =)', 0),
       (3, '1.1.1.1', '=)', 0),
       (4, '1.1.2.3', 'интересно!', 0),
       (5, '12.23.34.35', 'я его тоже найти не могу(', 0),
       (5, '1.4.23.77', 'а некоторые в теорию заговора не верят!', 0);

INSERT INTO comment (news_id, ip_address, text, is_deleted, parent_id)
VALUES (5, '1.4.23.78', 'я вот верю', 0, 10);

UPDATE comment
SET parent_id=11
WHERE comment_id = 10;

