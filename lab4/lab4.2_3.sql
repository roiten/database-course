use study;

# SELECT DISTINCT IF(u.name IS NOT NULL AND u.name != '', u.name, u.email) AS user
# FROM user u
#          INNER JOIN enrollment e ON u.user_id = e.user_id
#          INNER JOIN course c ON e.course_id = c.course_id
#          INNER JOIN quiz q ON c.course_id = q.quiz_id
#          INNER JOIN quiz_question qq ON q.quiz_id = qq.quiz_id
#          INNER JOIN attempt a ON e.enrollment_id = a.enrollment_id
#          INNER JOIN quiz_attempt_answer qaa ON a.attempt_id = qaa.attempt_id
#     AND qq.question_id = qaa.question_id
# WHERE u.state = 'active'
#   AND c.deletedAt IS NULL
#   AND q.state = 'published'
#   AND NOT EXISTS (
#     SELECT 1
#     FROM quiz_question qq2
#              LEFT JOIN multiple_question_available_values mcqav
#                 ON mcqav.question_id = qq2.question_id
#                     AND mcqav.value = qaa.answer_value
#                     AND mcqav.is_correct = 1
#              LEFT JOIN sequence_question_available_values sqav
#                 ON sqav.question_id = qq2.question_id
#                     AND sqav.value = qaa.answer_value
#                     AND sqav.value_order = qaa.answer_order
#     WHERE qq2.quiz_id = q.quiz_id
#         AND qq2.question_id = qaa.question_id
#         AND mcqav.question_id IS NULL
#         AND sqav.question_id IS NULL
# );

WITH UsersWithWrongAnswers AS (SELECT DISTINCT q.quiz_id, qq.question_id, qaa.attempt_id
FROM quiz q
    INNER JOIN quiz_question qq ON qq.quiz_id = q.quiz_id
    INNER JOIN quiz_attempt_answer qaa ON qq.question_id = qaa.question_id
         LEFT JOIN multiple_question_available_values mcqav
                   ON mcqav.question_id = qq.question_id
                       AND mcqav.value = qaa.answer_value
                       AND mcqav.is_correct = 1
         LEFT JOIN sequence_question_available_values sqav
                   ON sqav.question_id = qq.question_id
                       AND sqav.value = qaa.answer_value
                       AND sqav.value_order = qaa.answer_order
WHERE qq.quiz_id = q.quiz_id
  AND q.state = 'published'
  AND qq.question_id = qaa.question_id
  AND mcqav.question_id IS NULL
  AND sqav.question_id IS NULL),

UsersWithWrongQuiz AS (SELECT DISTINCT u.email, uwwa.quiz_id, e.enrollment_id
FROM UsersWithWrongAnswers uwwa
INNER JOIN attempt a ON uwwa.attempt_id = a.attempt_id
INNER JOIN enrollment e ON a.enrollment_id = e.enrollment_id
INNER JOIN user u ON u.user_id = e.user_id)

SELECT IF(u.name <> '', u.name, u.email) AS login
FROM enrollment e
LEFT JOIN UsersWithWrongQuiz uwwq ON e.course_id = uwwq.quiz_id AND uwwq.enrollment_id = e.enrollment_id
JOIN user u ON u.user_id = e.user_id
JOIN course c ON e.course_id = c.course_id
WHERE uwwq.quiz_id IS NULL
  AND c.courseType = 'quiz'
  AND u.state = 'active';


SELECT DISTINCT a.attempt_id, IF(u.name <> '', u.name, u.email) AS login, q.quiz_id
FROM attempt a
         LEFT JOIN quiz_attempt_answer qaa ON a.attempt_id = qaa.attempt_id
         LEFT JOIN enrollment e ON a.enrollment_id = e.enrollment_id
         LEFT JOIN user u ON e.user_id = u.user_id
         INNER JOIN quiz q ON e.course_id = q.quiz_id
WHERE qaa.answer_value = '' OR qaa.answer_value IS NULL;


# WITH fired AS (
#     SELECT IF(ISNULL(AVG(correct)), 0, AVG(correct)) AS avg_fired
#     FROM (
#              SELECT a.attempt_id, COUNT(DISTINCT qaa.question_id) AS correct
#              FROM user u
#                       JOIN enrollment e ON u.user_id = e.user_id
#                       JOIN attempt a ON a.enrollment_id = e.enrollment_id
#                       JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
#                       JOIN quiz_question qq ON qq.question_id = qaa.question_id
#                       LEFT JOIN multiple_question_available_values mcqav
#                                 ON mcqav.question_id = qaa.question_id
#                                     AND mcqav.value = qaa.answer_value
#                                     AND mcqav.is_correct = 1
#                       LEFT JOIN sequence_question_available_values sqav
#                                 ON sqav.question_id = qaa.question_id
#                                     AND sqav.value = qaa.answer_value
#                                     AND sqav.value_order = qaa.answer_order
#              WHERE u.state = 'fired'
#                AND a.start_date < '2025-01-01'
#                AND (mcqav.question_id IS NOT NULL OR sqav.question_id IS NOT NULL)
#              GROUP BY a.attempt_id
#          ) f
# ),
#      active AS (
#          SELECT AVG(correct) AS avg_active
#          FROM (
#                   SELECT a.attempt_id, COUNT(DISTINCT qaa.question_id) AS correct
#                   FROM user u
#                            JOIN enrollment e ON u.user_id = e.user_id
#                            JOIN attempt a ON a.enrollment_id = e.enrollment_id
#                            JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
#                            JOIN quiz_question qq ON qq.question_id = qaa.question_id
#                            LEFT JOIN multiple_question_available_values mcqav
#                                      ON mcqav.question_id = qaa.question_id
#                                          AND mcqav.value = qaa.answer_value
#                                          AND mcqav.is_correct = 1
#                            LEFT JOIN sequence_question_available_values sqav
#                                      ON sqav.question_id = qaa.question_id
#                                          AND sqav.value = qaa.answer_value
#                                          AND sqav.value_order = qaa.answer_order
#                   WHERE u.state = 'active'
#                     AND a.start_date >= '2025-01-01'
#                     AND (mcqav.question_id IS NOT NULL OR sqav.question_id IS NOT NULL)
#                   GROUP BY a.attempt_id
#               ) a
#      )
# SELECT
#     f.avg_fired,
#     a.avg_active,
#     CASE
#         WHEN f.avg_fired > a.avg_active THEN 'Уволенные пользователи лучше проходят квизы.'
#         WHEN f.avg_fired < a.avg_active THEN 'Активные пользователи лучше проходят квизы.'
#         ELSE 'Обе группы пользователей проходят квизы одинаково.'
#         END AS comparision
# FROM active a
#          JOIN fired f;


WITH fired AS (SELECT COUNT(DISTINCT qaa.question_id) AS cnt
FROM quiz q
    INNER JOIN course c ON q.quiz_id = c.course_id
    INNER JOIN quiz_question qq ON qq.quiz_id = q.quiz_id
    INNER JOIN quiz_attempt_answer qaa ON qq.question_id = qaa.question_id
    INNER JOIN attempt a ON qaa.attempt_id = a.attempt_id
    INNER JOIN enrollment e ON a.enrollment_id = e.enrollment_id
    INNER JOIN user u ON e.user_id = u.user_id
    LEFT JOIN multiple_question_available_values mcqav
        ON mcqav.question_id = qq.question_id
            AND mcqav.value = qaa.answer_value
            AND mcqav.is_correct = 1
    LEFT JOIN sequence_question_available_values sqav
        ON sqav.question_id = qq.question_id
            AND sqav.value = qaa.answer_value
            AND sqav.value_order = qaa.answer_order
WHERE
  c.name = 'FPM-quiz'
  AND qq.quiz_id = q.quiz_id
  AND a.start_date < '2025-01-01'
  AND q.state = 'published'
  AND u.state = 'fired'
  AND qq.question_id = qaa.question_id
  AND mcqav.question_id IS NULL
  AND sqav.question_id IS NULL),

active AS (SELECT COUNT(DISTINCT qaa.question_id) AS cnt
FROM quiz q
    INNER JOIN course c ON q.quiz_id = c.course_id
    INNER JOIN quiz_question qq ON qq.quiz_id = q.quiz_id
    INNER JOIN quiz_attempt_answer qaa ON qq.question_id = qaa.question_id
    INNER JOIN attempt a ON qaa.attempt_id = a.attempt_id
    INNER JOIN enrollment e ON a.enrollment_id = e.enrollment_id
    INNER JOIN user u ON e.user_id = u.user_id
    LEFT JOIN multiple_question_available_values mcqav
        ON mcqav.question_id = qq.question_id
            AND mcqav.value = qaa.answer_value
            AND mcqav.is_correct = 1
    LEFT JOIN sequence_question_available_values sqav
        ON sqav.question_id = qq.question_id
            AND sqav.value = qaa.answer_value
            AND sqav.value_order = qaa.answer_order
WHERE
  c.name = 'FPM-quiz'
  AND qq.quiz_id = q.quiz_id
  AND a.start_date >= '2025-01-01'
  AND q.state = 'published'
  AND u.state = 'active'
  AND qq.question_id = qaa.question_id
  AND mcqav.question_id IS NULL
  AND sqav.question_id IS NULL)

SELECT
    a.cnt AS 'Ошибок у активных',
    f.cnt AS 'Ошибок у уволенных',
    CASE
        WHEN f.cnt < a.cnt THEN 'Уволенные пользователи лучше проходят квизы.'
        WHEN f.cnt > a.cnt THEN 'Активные пользователи лучше проходят квизы.'
        ELSE 'Обе группы пользователей проходят квизы одинаково.'
        END AS comparision
FROM active a
         JOIN fired f;

# SELECT q.quiz_id, qq.question_id, qaa.attempt_id, u.email, qq.text, qaa.answer_value, qaa.answer_order
# FROM quiz q
#     INNER JOIN quiz_question qq ON qq.quiz_id = q.quiz_id
#     INNER JOIN quiz_attempt_answer qaa ON qq.question_id = qaa.question_id
#     INNER JOIN attempt a ON qaa.attempt_id = a.attempt_id
#     INNER JOIN enrollment e ON a.enrollment_id = e.enrollment_id
#     INNER JOIN user u ON e.user_id = u.user_id
#     INNER JOIN course c ON c.course_id = q.quiz_id
#     LEFT JOIN multiple_question_available_values mcqav
#         ON mcqav.question_id = qq.question_id
#             AND mcqav.value = qaa.answer_value
#             AND mcqav.is_correct = 1
#     LEFT JOIN sequence_question_available_values sqav
#         ON sqav.question_id = qq.question_id
#             AND sqav.value = qaa.answer_value
#             AND sqav.value_order = qaa.answer_order
# WHERE qq.quiz_id = q.quiz_id
#   AND q.state = 'published'
#   AND u.state = 'active'
#   AND c.name = 'FPM-quiz'
#   AND qq.question_id = qaa.question_id
#   AND mcqav.question_id IS NULL
#   AND sqav.question_id IS NULL;

SELECT qq.text, COUNT(DISTINCT a.attempt_id)
FROM user u
INNER JOIN enrollment e ON e.user_id = u.user_id
INNER JOIN course c ON c.course_id = e.course_id
INNER JOIN quiz q ON q.quiz_id = c.course_id
INNER JOIN attempt a ON a.enrollment_id = e.enrollment_id
INNER JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
INNER JOIN quiz_question qq ON qq.question_id = qaa.question_id
LEFT JOIN multiple_question_available_values mcav ON mcav.question_id = qaa.question_id
    AND mcav.value = qaa.answer_value
    AND mcav.is_correct
LEFT JOIN sequence_question_available_values sqav ON sqav.question_id = qaa.question_id
    AND sqav.value = qaa.answer_value
    AND sqav.value_order = qaa.answer_order
WHERE u.email = 'dasha@mail.ru'
    AND c.name = 'FPM-quiz'
    AND (mcav.question_id IS NOT NULL OR sqav.question_id IS NOT NULL)
GROUP BY qq.question_id;


# WITH correct_seq AS (
#     SELECT qaa.attempt_id, qaa.question_id
#     FROM quiz_attempt_answer qaa
#              JOIN sequence_question_available_values sqav
#                   ON sqav.question_id = qaa.question_id
#                       AND sqav.value = qaa.answer_value
#                       AND sqav.value_order = qaa.answer_order
#     GROUP BY qaa.attempt_id, qaa.question_id
#     HAVING COUNT(*) = (
#         SELECT COUNT(*) FROM sequence_question_available_values WHERE question_id = qaa.question_id
#     )
# )
#
# SELECT
#     IF(u.name IS NULL OR u.name = '', u.email, u.name) AS user_name,
#     COUNT(DISTINCT cs.question_id) AS total_score
# FROM user u
#          JOIN enrollment e ON e.user_id = u.user_id
#          JOIN course c ON c.course_id = e.course_id
#          JOIN quiz q ON q.quiz_id = c.course_id
#          JOIN attempt a ON a.enrollment_id = e.enrollment_id
#          JOIN correct_seq cs ON cs.attempt_id = a.attempt_id
# WHERE u.state = 'active'
#   AND q.state = 'published'
#   AND q.available_duration <= 600
# GROUP BY u.email
# ORDER BY total_score DESC
# LIMIT 10;


WITH sequence_question_count AS (
    SELECT
        question_id,
        COUNT(*) as questions_count
    FROM sequence_question_available_values
    GROUP BY question_id
),
attempt_question_correct AS (
    SELECT
        qaa.attempt_id,
        qaa.question_id,
        COUNT(DISTINCT qaa.answer_value) as correct_count
    FROM quiz_attempt_answer qaa
    JOIN sequence_question_available_values sqav
        ON sqav.question_id = qaa.question_id
            AND sqav.value = qaa.answer_value
            AND sqav.value_order = qaa.answer_order
    GROUP BY qaa.attempt_id, qaa.question_id
)

SELECT
    IF(u.name IS NULL OR u.name = '', u.email, u.name) AS user_name,
    COUNT(DISTINCT aqq.question_id) AS total_score
FROM user u
    JOIN enrollment e ON e.user_id = u.user_id
    JOIN course c ON c.course_id = e.course_id
    JOIN quiz q ON q.quiz_id = c.course_id
    JOIN attempt a ON a.enrollment_id = e.enrollment_id
    JOIN attempt_question_correct aqq ON aqq.attempt_id = a.attempt_id
    JOIN sequence_question_count sqc
        ON sqc.question_id = aqq.question_id
            AND aqq.correct_count = sqc.questions_count
WHERE u.state = 'active'
  AND q.state = 'published'
#   AND q.available_duration <= 600
GROUP BY u.user_id, u.email
ORDER BY total_score DESC
LIMIT 10;