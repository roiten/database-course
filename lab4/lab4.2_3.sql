use study;

WITH wrong_attempts AS (
    SELECT DISTINCT a.attempt_id
    FROM attempt a
        JOIN enrollment e ON e.enrollment_id = a.enrollment_id
        JOIN quiz q ON q.quiz_id = e.course_id
        JOIN quiz_question qq ON qq.quiz_id = q.quiz_id
        LEFT JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id AND qaa.question_id = qq.question_id
        LEFT JOIN multiple_question_available_values mq ON mq.question_id = qq.question_id AND qq.type = 'multiple_choice'
        LEFT JOIN sequence_question_available_values sq ON sq.question_id = qq.question_id AND qq.type = 'sequence'
    WHERE (
        (qq.type = 'multiple_choice'
            AND ((mq.is_correct = FALSE AND qaa.answer_value = mq.value)
            OR (mq.is_correct = TRUE AND qaa.answer_value IS NULL))
        )
        OR
        (qq.type = 'sequence'
            AND NOT EXISTS (
                SELECT 1
                FROM quiz_attempt_answer qaa2
                WHERE qaa2.attempt_id = a.attempt_id
                    AND qaa2.question_id = qq.question_id
                    AND qaa2.answer_value = sq.value
                    AND qaa2.answer_order = sq.value_order
            )
        ))
)

SELECT DISTINCT IF(u.name IS NULL OR u.name = '', u.email, u.name) AS user_name
FROM user u
    INNER JOIN enrollment e ON e.user_id = u.user_id
    INNER JOIN course c ON c.course_id = e.course_id
    INNER JOIN quiz q ON q.quiz_id = c.course_id
    INNER JOIN attempt a ON a.enrollment_id = e.enrollment_id
WHERE u.state = 'active'
  AND c.deletedAt IS NULL
  AND q.state = 'published'
  AND NOT EXISTS (
    SELECT 1
    FROM wrong_attempts wa
    WHERE wa.attempt_id = a.attempt_id
);


SELECT DISTINCT IF(u.name IS NOT NULL AND u.name != '', u.name, u.email) AS user
FROM user u
         INNER JOIN enrollment e ON u.user_id = e.user_id
         INNER JOIN course c ON e.course_id = c.course_id
         INNER JOIN quiz q ON c.course_id = q.quiz_id
         INNER JOIN quiz_question qq ON q.quiz_id = qq.quiz_id
         INNER JOIN attempt a ON e.enrollment_id = a.enrollment_id
         INNER JOIN quiz_attempt_answer qaa ON a.attempt_id = qaa.attempt_id
    AND qq.question_id = qaa.question_id
WHERE u.state = 'active'
  AND c.deletedAt IS NULL
  AND q.state = 'published'
  AND NOT EXISTS (
    SELECT 1
    FROM quiz_question qq2
             LEFT JOIN multiple_question_available_values mcqav
                ON mcqav.question_id = qq2.question_id
                    AND mcqav.value = qaa.answer_value
                    AND mcqav.is_correct = 1
             LEFT JOIN sequence_question_available_values sqav
                ON sqav.question_id = qq2.question_id
                    AND sqav.value = qaa.answer_value
                    AND sqav.value_order = qaa.answer_order
    WHERE qq2.quiz_id = q.quiz_id
        AND qq2.question_id = qaa.question_id
        AND mcqav.question_id IS NULL
        AND sqav.question_id IS NULL
);


SELECT q.quiz_id, qq2.question_id
FROM quiz_question qq2
    INNER JOIN  quiz_attempt_answer qaa ON qq2.question_id = qaa.question_id
    INNER JOIN quiz q ON qq2.quiz_id = q.quiz_id
         LEFT JOIN multiple_question_available_values mcqav
                   ON mcqav.question_id = qq2.question_id
                       AND mcqav.value = qaa.answer_value
                       AND mcqav.is_correct = 1
         LEFT JOIN sequence_question_available_values sqav
                   ON sqav.question_id = qq2.question_id
                       AND sqav.value = qaa.answer_value
                       AND sqav.value_order = qaa.answer_order
WHERE qq2.quiz_id = UUID_TO_BIN('00efde35-4e58-411d-b158-77b8202711ee')
  AND qq2.question_id = qaa.question_id
  AND mcqav.question_id IS NULL
  AND sqav.question_id IS NULL;

SELECT DISTINCT a.attempt_id, IF(u.name <> '', u.name, u.email) AS login, q.quiz_id
FROM attempt a
         LEFT JOIN quiz_attempt_answer qaa ON a.attempt_id = qaa.attempt_id
         LEFT JOIN enrollment e ON a.enrollment_id = e.enrollment_id
         LEFT JOIN user u ON e.user_id = u.user_id
         INNER JOIN quiz q ON e.course_id = q.quiz_id
WHERE qaa.answer_value = '' OR qaa.answer_value IS NULL;



WITH fired AS (
    SELECT IF(ISNULL(AVG(correct)), 0, AVG(correct)) AS avg_fired
    FROM (
             SELECT a.attempt_id, COUNT(DISTINCT qaa.question_id) AS correct
             FROM user u
                      JOIN enrollment e ON u.user_id = e.user_id
                      JOIN attempt a ON a.enrollment_id = e.enrollment_id
                      JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
                      JOIN quiz_question qq ON qq.question_id = qaa.question_id
                      LEFT JOIN multiple_question_available_values mcqav
                                ON mcqav.question_id = qaa.question_id
                                    AND mcqav.value = qaa.answer_value
                                    AND mcqav.is_correct = 1
                      LEFT JOIN sequence_question_available_values sqav
                                ON sqav.question_id = qaa.question_id
                                    AND sqav.value = qaa.answer_value
                                    AND sqav.value_order = qaa.answer_order
             WHERE u.state = 'fired'
               AND a.start_date < '2025-01-01'
               AND (mcqav.question_id IS NOT NULL OR sqav.question_id IS NOT NULL)
             GROUP BY a.attempt_id
         ) f
),
     active AS (
         SELECT AVG(correct) AS avg_active
         FROM (
                  SELECT a.attempt_id, COUNT(DISTINCT qaa.question_id) AS correct
                  FROM user u
                           JOIN enrollment e ON u.user_id = e.user_id
                           JOIN attempt a ON a.enrollment_id = e.enrollment_id
                           JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
                           JOIN quiz_question qq ON qq.question_id = qaa.question_id
                           LEFT JOIN multiple_question_available_values mcqav
                                     ON mcqav.question_id = qaa.question_id
                                         AND mcqav.value = qaa.answer_value
                                         AND mcqav.is_correct = 1
                           LEFT JOIN sequence_question_available_values sqav
                                     ON sqav.question_id = qaa.question_id
                                         AND sqav.value = qaa.answer_value
                                         AND sqav.value_order = qaa.answer_order
                  WHERE u.state = 'active'
                    AND a.start_date >= '2025-01-01'
                    AND (mcqav.question_id IS NOT NULL OR sqav.question_id IS NOT NULL)
                  GROUP BY a.attempt_id
              ) a
     )
SELECT
    f.avg_fired,
    a.avg_active,
    CASE
        WHEN f.avg_fired > a.avg_active THEN 'Уволенные пользователи лучше проходят квизы.'
        WHEN f.avg_fired < a.avg_active THEN 'Активные пользователи лучше проходят квизы.'
        ELSE 'Обе группы пользователей проходят квизы одинаково.'
        END AS comparision
FROM active a
         JOIN fired f;



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


WITH correct_seq AS (
    SELECT qaa.attempt_id, qaa.question_id
    FROM quiz_attempt_answer qaa
             JOIN sequence_question_available_values sqav
                  ON sqav.question_id = qaa.question_id
                      AND sqav.value = qaa.answer_value
                      AND sqav.value_order = qaa.answer_order
    GROUP BY qaa.attempt_id, qaa.question_id
    HAVING COUNT(*) = (
        SELECT COUNT(*) FROM sequence_question_available_values WHERE question_id = qaa.question_id
    )
)

SELECT
    IF(u.name IS NULL OR u.name = '', u.email, u.name) AS user_name,
    COUNT(DISTINCT cs.question_id) AS total_score
FROM user u
         JOIN enrollment e ON e.user_id = u.user_id
         JOIN course c ON c.course_id = e.course_id
         JOIN quiz q ON q.quiz_id = c.course_id
         JOIN attempt a ON a.enrollment_id = e.enrollment_id
         JOIN correct_seq cs ON cs.attempt_id = a.attempt_id
WHERE u.state = 'active'
  AND q.state = 'published'
  AND q.available_duration <= 600
GROUP BY u.email
ORDER BY total_score DESC
LIMIT 10;