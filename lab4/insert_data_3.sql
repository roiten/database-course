USE study;

INSERT INTO `user` (user_id, name, email, state)
VALUES (UUID_TO_BIN(UUID()), 'ivan', 'ivan@email.com', 'fired'),
       (UUID_TO_BIN(UUID()), 'boris', 'boris@email.com', 'unactive'),
       (UUID_TO_BIN(UUID()), 'gleb', 'gleb@email.com', 'active'),
       (UUID_TO_BIN(UUID()), 'alex', 'alex@email.com', 'active'),
       (UUID_TO_BIN(UUID()), 'mikhail', 'mikhail@email.com', 'active'),
       (UUID_TO_BIN(UUID()), 'lena', 'lena@mail.ru', 'active'),
       (UUID_TO_BIN(UUID()), 'tanya', 'tanya@mail.ru', 'active'),
       (UUID_TO_BIN(UUID()), '', 'dasha@mail.ru', 'active'),
       (UUID_TO_BIN(UUID()), 'masha', 'masha@mail.ru', 'active'),
       (UUID_TO_BIN(UUID()), 'sasha', 'sasha@mail.ru', 'active');

SET @c1 = UUID();
SET @c2 = UUID();
SET @c3 = UUID();
SET @c4 = UUID();
SET @c5 = UUID();
SET @c6 = UUID();

INSERT INTO `course` (course_id, name, courseType, description)
VALUES (UUID_TO_BIN(@c1), 'Fish turns out 24h', 'video', 'ryba vertitsya'),
       (UUID_TO_BIN(@c2), 'Nature', 'video', null),
       (UUID_TO_BIN(@c3), 'Tihii Den', 'audio', 'audiokniga'),
       (UUID_TO_BIN(@c4), 'Docker', 'audio', 'all about docker during 48h'),
       (UUID_TO_BIN(@c5), 'arab quiz', 'quiz', 'good luck'),
       (UUID_TO_BIN(@c6), 'FPM-quiz', 'quiz', 'how many super folders could you make?');

INSERT INTO `video` (video_id, source_url, format, duration, size)
VALUES (UUID_TO_BIN(@c1), 'https://tube.pro/fish.mp4', 'mp4', 3600, 123000),
       (UUID_TO_BIN(@c2), 'https://google-video/nature.mp4', 'mp4', 5400, 980000);

INSERT INTO `audio` (audio_id, source_url, duration)
VALUES (UUID_TO_BIN(@c3), 'https://music.yandex.ru/tihii-den.mp3', 2700),
       (UUID_TO_BIN(@c4), 'https://oeker.hub/docker.mp3', 3200);

INSERT INTO `quiz` (quiz_id, source_url, weight, available_duration, state)
VALUES (UUID_TO_BIN(@c5), null, 10, 1800, 'published'),
       (UUID_TO_BIN(@c6), null, 8, 1200, 'published');

SET @m1 = UUID();
SET @m2 = UUID();
SET @m3 = UUID();
SET @m4 = UUID();

INSERT INTO `quiz_mark` (mark_id, quiz_id, mark, min_score, max_score)
VALUES (UUID_TO_BIN(@m1), UUID_TO_BIN(@c5), 5, 90, 100),
       (UUID_TO_BIN(@m2), UUID_TO_BIN(@c5), 4, 70, 89),
       (UUID_TO_BIN(@m3), UUID_TO_BIN(@c5), 3, 50, 69),
       (UUID_TO_BIN(@m4), UUID_TO_BIN(@c5), 2, 0, 49);

SET @q1 = UUID();
SET @q2 = UUID();
SET @q3 = UUID();
SET @q4 = UUID();
SET @q5 = UUID();
SET @q6 = UUID();

INSERT INTO quiz_question (question_id, quiz_id, text, type, order_index)
VALUES (UUID_TO_BIN(@q1), UUID_TO_BIN(@c5), 'How long does the fish spin?', 'multiple_choice', 1),
       (UUID_TO_BIN(@q2), UUID_TO_BIN(@c5), 'The main character of Tihii Den', 'multiple_choice', 2),
       (UUID_TO_BIN(@q3), UUID_TO_BIN(@c5), 'Top 3 docker commands to broke a container', 'sequence', 3),
       (UUID_TO_BIN(@q4), UUID_TO_BIN(@c6), 'The best ways to name folder', 'multiple_choice', 1),
       (UUID_TO_BIN(@q5), UUID_TO_BIN(@c6), 'Sort these folder names', 'sequence', 2),
       (UUID_TO_BIN(@q6), UUID_TO_BIN(@c6), 'How long does the fish spin?', 'multiple_choice', 3);

INSERT INTO `multiple_question_available_values` (question_id, option_number, value, is_correct)
VALUES (UUID_TO_BIN(@q1), 1, 'while the tube is hosting', false),
       (UUID_TO_BIN(@q1), 2, '24 hours', true),
       (UUID_TO_BIN(@q1), 3, 'until someone stops it', false),
       (UUID_TO_BIN(@q1), 4, 'it never spins', false),
       (UUID_TO_BIN(@q2), 1, 'cleaner', true),
       (UUID_TO_BIN(@q2), 2, 'gangster', false),
       (UUID_TO_BIN(@q2), 3, 'ios-developer', false),
       (UUID_TO_BIN(@q4), 1, 'super-folder', true),
       (UUID_TO_BIN(@q4), 2, 'myfolder', false),
       (UUID_TO_BIN(@q4), 3, 'mv -r /opt ~/super-folder', true),
       (UUID_TO_BIN(@q4), 4, 'use code convensions', false),
       (UUID_TO_BIN(@q6), 1, 'while the tube is hosting', false),
       (UUID_TO_BIN(@q6), 2, '24 hours', true),
       (UUID_TO_BIN(@q6), 3, 'until someone stops it', false),
       (UUID_TO_BIN(@q6), 4, 'it never spins', false);

INSERT INTO `sequence_question_available_values` (question_id, value, value_order)
VALUES (UUID_TO_BIN(@q3), 'docker pull', 1),
       (UUID_TO_BIN(@q3), 'docker build', 2),
       (UUID_TO_BIN(@q3), 'docker run', 3),
       (UUID_TO_BIN(@q3), 'docker stop', 4),
       (UUID_TO_BIN(@q5), 'super-folder', 1),
       (UUID_TO_BIN(@q5), 'super-folder2', 2),
       (UUID_TO_BIN(@q5), 'super-final-folder', 3),
       (UUID_TO_BIN(@q5), 'super-final-folder-ultra', 4);

SET @e1 = UUID();
SET @e2 = UUID();
SET @e3 = UUID();
SET @e4 = UUID();
SET @e5 = UUID();
SET @e6 = UUID();
SET @e7 = UUID();

INSERT INTO `enrollment` (enrollment_id, user_id, course_id, start_date)
VALUES (UUID_TO_BIN(@e1), (SELECT user_id FROM user WHERE email = 'ivan@email.com'), UUID_TO_BIN(@c6),
        '2025-09-01 09:00:00'),
       (UUID_TO_BIN(@e2), (SELECT user_id FROM user WHERE email = 'ivan@email.com'), UUID_TO_BIN(@c5),
        '2025-09-02 09:00:00'),
       (UUID_TO_BIN(@e3), (SELECT user_id FROM user WHERE email = 'boris@email.com'), UUID_TO_BIN(@c5),
        '2026-01-01 10:00:00'),
       (UUID_TO_BIN(@e4), (SELECT user_id FROM user WHERE email = 'lena@mail.ru'), UUID_TO_BIN(@c3),
        '2025-12-31 23:59:11'),
       (UUID_TO_BIN(@e5), (SELECT user_id FROM user WHERE email = 'tanya@mail.ru'), UUID_TO_BIN(@c6),
        '2020-02-05 14:00:00'),
       (UUID_TO_BIN(@e6), (SELECT user_id FROM user WHERE email = 'dasha@mail.ru'), UUID_TO_BIN(@c6),
        '2020-02-05 14:00:00'),
       (UUID_TO_BIN(@e7), (SELECT user_id FROM user WHERE email = 'gleb@email.com'), UUID_TO_BIN(@c6),
        '2020-02-05 14:00:00');

SET @a1 = UUID();
SET @a2 = UUID();
SET @a3 = UUID();
SET @a4 = UUID();
SET @a5 = UUID();
SET @a6 = UUID();

INSERT INTO `attempt` (attempt_id, enrollment_id, start_date, duration, score)
VALUES
    (UUID_TO_BIN(@a1), UUID_TO_BIN(@e2), '2024-01-20 10:00:00', 900, 60),
       (UUID_TO_BIN(@a2), UUID_TO_BIN(@e3), '2026-01-21 11:30:00', 1200, 40),
       (UUID_TO_BIN(@a3), UUID_TO_BIN(@e5), '2026-02-11 15:40:00', 299, 100),
       (UUID_TO_BIN(@a4), UUID_TO_BIN(@e6), '2026-02-11 15:44:00', 280, 88),
       (UUID_TO_BIN(@a5), UUID_TO_BIN(@e7), '2026-02-11 17:01:00', 300, 100),
       (UUID_TO_BIN(@a6), UUID_TO_BIN(@e1), '2024-02-11 17:01:00', 300, 100);

INSERT INTO `quiz_attempt_answer` (attempt_id, question_id, answer_value)
VALUES (UUID_TO_BIN(@a1), UUID_TO_BIN(@q1), '24 hours'),
       (UUID_TO_BIN(@a1), UUID_TO_BIN(@q2), 'gangster'),
#        (UUID_TO_BIN(@a1), UUID_TO_BIN(@q3), 'docker pull,docker run,docker build,docker stop'),

       (UUID_TO_BIN(@a2), UUID_TO_BIN(@q1), ''),
       (UUID_TO_BIN(@a2), UUID_TO_BIN(@q2), ''),

       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q4), 'mv -r /opt ~/super-folder'),
       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q4), 'super-folder'),
#        (UUID_TO_BIN(@a3), UUID_TO_BIN(@q5), 'super-folder,super-folder2,super-final-folder,super-final-folder-ultra'),
       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q6), '24 hours'),

       (UUID_TO_BIN(@a4), UUID_TO_BIN(@q4), 'super-folder'),
#        (UUID_TO_BIN(@a4), UUID_TO_BIN(@q5), ''),
       (UUID_TO_BIN(@a4), UUID_TO_BIN(@q6), 'while the tube is hosting'),

       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q4), 'mv -r /opt ~/super-folder'),
       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q4), 'super-folder'),
#        (UUID_TO_BIN(@a5), UUID_TO_BIN(@q5), 'super-folder,super-folder2,super-final-folder,super-final-folder-ultra'),
       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q6), '24 hours'),

       (UUID_TO_BIN(@a6), UUID_TO_BIN(@q4), '24 hours'),
       (UUID_TO_BIN(@a6), UUID_TO_BIN(@q5), '24 hours'),
       (UUID_TO_BIN(@a6), UUID_TO_BIN(@q6), '4 hours');

INSERT INTO `quiz_attempt_answer` (attempt_id, question_id, answer_value, answer_order)
VALUES (UUID_TO_BIN(@a1), UUID_TO_BIN(@q3), 'docker pull', 1),
       (UUID_TO_BIN(@a1), UUID_TO_BIN(@q3), 'docker run', 2),
       (UUID_TO_BIN(@a1), UUID_TO_BIN(@q3), 'docker build', 3),
       (UUID_TO_BIN(@a1), UUID_TO_BIN(@q3), 'docker stop', 4),


       (UUID_TO_BIN(@a4), UUID_TO_BIN(@q5), '', NULL),

       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q5), 'super-folder', 1),
       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q5), 'super-folder2', 2),
       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q5), 'super-final-folder', 3),
       (UUID_TO_BIN(@a3), UUID_TO_BIN(@q5), 'super-final-folder-ultra', 4),

       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q5), 'super-folder', 1),
       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q5), 'super-folder2', 2),
       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q5), 'super-final-folder', 3),
       (UUID_TO_BIN(@a5), UUID_TO_BIN(@q5), 'super-final-folder-ultra', 4);


