# ЗАДАНИЕ 1.
# Создайте БД для модуля новостной ленты на основании ER диаграммы из предыдущей лабораторной работы. Дополнительные требования:
# Как минимум один идентификатор должен быть числовым
# Как минимум один идентификатор должен быть типа UUID
# Как минимум один идентификатор должен быть типа VARCHAR
# Уникальные столбцы в таблице должны гарантировать уникальность на уровне схемы базы данных
# Добавьте как минимум 2 новых отношения на своё усмотрение. Отношения должны содержать не менее 5 атрибутов и могут быть связаны через вспомогательные таблицы.
# Добавьте как минимум по 3 новых поля (поля придумаете сами) в 2 отношения через изменение существующей таблицы

-- замечания
--   с id проблема + наименования
--   c размером строк
--   наименования табличек (небольшая правка peace_of.. в news, news_item и преименовать news_feed

DROP DATABASE IF EXISTS `news_feed`;
CREATE DATABASE IF NOT EXISTS `news_feed`;
USE `news_feed`;

CREATE TABLE IF NOT EXISTS news_item
(
    `news_id`      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`         VARCHAR(255)        NOT NULL,
    `author_id`    INT UNSIGNED        NOT NULL,
    `thread_id`    VARCHAR(255)      DEFAULT NULL,
    `is_published` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `news_block`
(
    `block_id` BINARY(16)       NOT NULL PRIMARY KEY,
    `news_id`  INT UNSIGNED     NOT NULL,
    `position` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    UNIQUE (`news_id`, `position`),
    FOREIGN KEY (`news_id`) REFERENCES news_item (`news_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `text_block`
(
    `block_id` BINARY(16) NOT NULL PRIMARY KEY,
    `text`     TEXT       NOT NULL,
    FOREIGN KEY (`block_id`) REFERENCES `news_block` (`block_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `image_block`
(
    `block_id` BINARY(16) NOT NULL PRIMARY KEY,
    `image`    LONGBLOB   NOT NULL,
    FOREIGN KEY (`block_id`) REFERENCES `news_block` (`block_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `news_view`
(
    `news_id`    INT UNSIGNED NOT NULL,
    `ip_address` VARCHAR(40)  NOT NULL,
    `view_time`  DATETIME     NOT NULL DEFAULT NOW(),

    FOREIGN KEY (`news_id`) REFERENCES news_item (`news_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `comment`
(
    `comment_id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `news_id`    INT UNSIGNED        NOT NULL,
    `ip_address` VARCHAR(40)         NOT NULL,
    `text`       TEXT                NOT NULL,
    `is_deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
    `parent_id`  INT UNSIGNED        NULL,

    FOREIGN KEY (`parent_id`) REFERENCES `comment` (`comment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (`news_id`) REFERENCES news_item (`news_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `video_block`
(
    `block_id`  BINARY(16)    NOT NULL PRIMARY KEY,
    `video_url` VARCHAR(512) NOT NULL UNIQUE,
    `size_bytes` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    FOREIGN KEY (`block_id`) REFERENCES `news_block` (`block_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `author`
(
    `author_id`  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(255)        NOT NULL,
    `email`      VARCHAR(100)        NOT NULL UNIQUE,
    `bio`        TEXT                NULL,
    `created_at` DATETIME            NOT NULL DEFAULT NOW(),
    `is_active`  TINYINT(1) UNSIGNED NOT NULL DEFAULT 0
)
    ENGINE = InnoDB
    CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

ALTER TABLE news_item
    ADD FOREIGN KEY (`author_id`) REFERENCES `author` (`author_id`) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS `thread`
(
    `thread_id`   VARCHAR(255) NOT NULL PRIMARY KEY,
    `title`       VARCHAR(255) NOT NULL,
    `description` TEXT         NULL,
    `created_by`  INT UNSIGNED NULL,
    `created_at`  DATETIME     NOT NULL DEFAULT NOW(),
    `is_locked`   TINYINT(1)   NOT NULL DEFAULT 0,
    FOREIGN KEY (`created_by`) REFERENCES `author` (`author_id`) ON DELETE SET NULL ON UPDATE CASCADE
)
    ENGINE = InnoDB
    CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci;

ALTER TABLE `author`
    ADD COLUMN `last_login` DATETIME                NOT NULL DEFAULT NOW(),
    ADD COLUMN `avatar`     BLOB                    NULL,
    ADD COLUMN `gender`     ENUM ('male', 'female') NULL     DEFAULT NULL;

ALTER TABLE `thread`
    ADD COLUMN `is_visible` TINYINT(1) NOT NULL DEFAULT 1,
    ADD COLUMN `color_code` VARCHAR(7) NOT NULL DEFAULT '#FFFFFF',
    ADD COLUMN `is_starred` TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE `news_view`
    ADD UNIQUE INDEX `uk_news_view_unique` (`news_id`, `ip_address`);