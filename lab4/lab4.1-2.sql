DROP DATABASE IF EXISTS `study_v2`;
CREATE DATABASE IF NOT EXISTS `study_v2`;

USE `study_v2`;

CREATE TABLE IF NOT EXISTS `course`
(
    `course_id`   BINARY(16) PRIMARY KEY,
    `name`        VARCHAR(255) NOT NULL DEFAULT 'New course',
    `courseType`  ENUM ('audio', 'video', 'quiz'),
    `description` TEXT,
    `createdAt`   TIMESTAMP             DEFAULT NOW(),
    `deletedAt`   TIMESTAMP             DEFAULT NULL
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `video`
(
    `course_id`  BINARY(16) PRIMARY KEY,
    `source_url` TEXT,
    `format`     ENUM ('mp4', 'avi'),
    `duration`   INT UNSIGNED NOT NULL,
    `size`       INT UNSIGNED NOT NULL,
    FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audio`
(
    `course_id`  BINARY(16) PRIMARY KEY,
    `source_url` TEXT,
    `duration`   INT UNSIGNED,
    FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz`
(
    `course_id`          BINARY(16) PRIMARY KEY,
    `source_url`         TEXT,
    `weight`             INT UNSIGNED,
    `available_duration` INT UNSIGNED NULL,
    `state`              ENUM ('draft', 'published', 'uploaded') DEFAULT 'draft',
    FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_mark`
(
    `mark_id`   BINARY(16) PRIMARY KEY,
    `course_id` BINARY(16)   NOT NULL,
    `mark`      INT UNSIGNED NOT NULL,
    `min_score` INT UNSIGNED NOT NULL,
    `max_score` INT UNSIGNED NOT NULL,
    FOREIGN KEY (`course_id`) REFERENCES `quiz` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_question`
(
    `question_id` BINARY(16) PRIMARY KEY,
    `quiz_id`     BINARY(16)                           NOT NULL,
    `text`        TEXT                                 NOT NULL,
    `type`        ENUM ('multiple_choice', 'sequence') NOT NULL DEFAULT 'multiple_choice',
    `picture_url` TEXT,
    `order_index` INT UNSIGNED                                  DEFAULT 0,
    FOREIGN KEY (`quiz_id`) REFERENCES `quiz` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `multiple_question_values`
(
    `value_id`    BINARY(16) PRIMARY KEY,
    `question_id` BINARY(16) NOT NULL,
    `value`       TEXT       NOT NULL,
    `is_correct`  BOOLEAN    NOT NULL DEFAULT FALSE,
    FOREIGN KEY (`question_id`) REFERENCES `quiz_question` (`question_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `sequence_question_values`
(
    `value_id`    BINARY(16) PRIMARY KEY,
    `question_id` BINARY(16) NOT NULL,
    `value`       TEXT       NOT NULL,
    `position`    INT UNSIGNED DEFAULT NULL,
    UNIQUE (`question_id`, `position`),
    FOREIGN KEY (`question_id`) REFERENCES `quiz_question` (`question_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user`
(
    `user_id`    BINARY(16) PRIMARY KEY,
    `name`       VARCHAR(255),
    `email`      VARCHAR(255) NOT NULL UNIQUE,
    `state`      ENUM ('active', 'unactive', 'fired') DEFAULT 'unactive',
    `created_at` TIMESTAMP                            DEFAULT NOW(),
    `deleted_at` TIMESTAMP    NULL
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `enrollment`
(
    `enrollment_id` BINARY(16) PRIMARY KEY,
    `user_id`       BINARY(16) NOT NULL,
    `course_id`     BINARY(16) NOT NULL,
    `start_date`    TIMESTAMP DEFAULT NOW(),
    `end_date`      TIMESTAMP  NULL,
    FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `attempt`
(
    `attempt_id`    BINARY(16) PRIMARY KEY,
    `enrollment_id` BINARY(16) NOT NULL,
    `start_date`    TIMESTAMP    DEFAULT NOW(),
    `end_date`      TIMESTAMP  NULL,
    `score`         INT UNSIGNED DEFAULT 0,
    `duration`      INT UNSIGNED,
    FOREIGN KEY (`enrollment_id`) REFERENCES `enrollment` (`enrollment_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_attempt_answer`
(
    `answer_id`         BINARY(16) PRIMARY KEY,
    `attempt_id`        BINARY(16) NOT NULL,
    `question_id`       BINARY(16) NOT NULL,
    `value`             TEXT,
    `position`          INT UNSIGNED,
    FOREIGN KEY (`question_id`) REFERENCES `quiz_question` (`question_id`) ON DELETE CASCADE,
    FOREIGN KEY (`attempt_id`) REFERENCES `attempt` (`attempt_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

