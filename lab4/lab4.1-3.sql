DROP DATABASE IF EXISTS `study`;
CREATE DATABASE IF NOT EXISTS `study`;

USE `study`;

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
    `video_id`   BINARY(16) PRIMARY KEY,
    `source_url` VARCHAR(2000),
    `format`     ENUM ('mp4', 'avi') NOT NULL,
    `duration`   INT UNSIGNED        NOT NULL,
    `size`       INT UNSIGNED        NOT NULL,
    FOREIGN KEY (`video_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audio`
(
    `audio_id`   BINARY(16) PRIMARY KEY,
    `source_url` VARCHAR(2000),
    `duration`   INT UNSIGNED,
    FOREIGN KEY (`audio_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz`
(
    `quiz_id`            BINARY(16) PRIMARY KEY,
    `source_url`         VARCHAR(2000),
    `weight`             INT UNSIGNED                                            NOT NULL,
    `available_duration` INT UNSIGNED                                            NOT NULL,
    `state`              ENUM ('draft', 'published', 'uploaded') DEFAULT 'draft' NOT NULL,
    FOREIGN KEY (`quiz_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_mark`
(
    `mark_id`   BINARY(16) PRIMARY KEY,
    `quiz_id`   BINARY(16)   NOT NULL,
    `mark`      INT UNSIGNED NOT NULL,
    `min_score` INT UNSIGNED NOT NULL,
    `max_score` INT UNSIGNED NOT NULL,
    FOREIGN KEY (`quiz_id`) REFERENCES `quiz` (`quiz_id`) ON DELETE CASCADE
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
    `answer`      VARCHAR(2000)                        NOT NULL DEFAULT '',
    `picture_url` VARCHAR(2000),
    `order_index` INT UNSIGNED                                  DEFAULT 0,
    FOREIGN KEY (`quiz_id`) REFERENCES `quiz` (`quiz_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `multiple_question_available_values`
(
    `question_id`   BINARY(16)   NOT NULL,
    `option_number` INT UNSIGNED NOT NULL DEFAULT 1,
    `value`         VARCHAR(100) NOT NULL DEFAULT '',
    `is_correct`    BOOLEAN      NOT NULL DEFAULT FALSE,
    PRIMARY KEY (`question_id`, `option_number`),
    FOREIGN KEY (`question_id`) REFERENCES `quiz_question` (`question_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `sequence_question_available_values`
(
    `question_id` BINARY(16)   NOT NULL,
    `value`       VARCHAR(100) NOT NULL DEFAULT '',
    `value_order` INT UNSIGNED          DEFAULT 1,
    PRIMARY KEY (`question_id`, `value_order`),
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
    FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `attempt`
(
    `attempt_id`    BINARY(16) PRIMARY KEY,
    `enrollment_id` BINARY(16)   NOT NULL,
    `start_date`    TIMESTAMP    DEFAULT NOW(),
    `duration`      INT UNSIGNED NOT NULL,
    `score`         INT UNSIGNED DEFAULT 0,
    FOREIGN KEY (`enrollment_id`) REFERENCES `enrollment` (`enrollment_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quiz_attempt_answer`
(
    `answer_id`    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `attempt_id`   BINARY(16)   NOT NULL,
    `question_id`  BINARY(16)   NOT NULL,
    `answer_value` VARCHAR(100) NOT NULL DEFAULT '',
    `answer_order` INT UNSIGNED          DEFAULT NULL,
    FOREIGN KEY (`question_id`) REFERENCES `quiz_question` (`question_id`) ON DELETE CASCADE,
    FOREIGN KEY (`attempt_id`) REFERENCES `attempt` (`attempt_id`) ON DELETE CASCADE
)
    ENGINE = InnoDB
    CHARACTER SET = utf8mb4
    COLLATE utf8mb4_unicode_ci;



CREATE INDEX idx_user_state ON user (state);
CREATE INDEX idx_quiz_state ON quiz (state);
CREATE INDEX idx_enrollment_user ON enrollment (user_id);
CREATE INDEX idx_enrollment_course ON enrollment (course_id);
CREATE INDEX idx_attempt_answer ON quiz_attempt_answer (attempt_id, question_id, answer_value);
CREATE INDEX idx_sqav ON sequence_question_available_values (question_id, value, value_order);
CREATE INDEX idx_mqav ON multiple_question_available_values (question_id, value, is_correct);
CREATE INDEX idx_question_quiz ON quiz_question (quiz_id, type);
