use study;

SELECT IF(u.name <> '', u.name, u.email)
FROM user u
    INNER JOIN enrollment e ON e.user_id = u.user_id
    INNER JOIN course c ON c.course_id = e.course_id
    INNER JOIN quiz q ON q.quiz_id = c.course_id
    INNER JOIN attempt a ON a.enrollment_id = e.enrollment_id
    INNER JOIN quiz_question qa ON qa.quiz_id = q.quiz_id
    INNER JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id AND qaa.question_id = qa.question_id AND qaa.answer_value = qa.answer
WHERE u.state = 'active'
    AND c.deletedAt IS NULL
    AND c.name = 'FPM-quiz'
    AND q.state = 'published'
GROUP BY u.user_id, u.email, a.attempt_id
HAVING COUNT(qa.question_id) = COUNT(qaa.answer_value);


SELECT a.attempt_id, IF(u.name <> '', u.name, u.email) AS login, q.quiz_id
FROM attempt a
         LEFT JOIN quiz_attempt_answer qaa ON a.attempt_id = qaa.attempt_id
         LEFT JOIN enrollment e ON a.enrollment_id = e.enrollment_id
         LEFT JOIN user u ON e.user_id = u.user_id
         INNER JOIN quiz q ON e.course_id = q.quiz_id
WHERE qaa.answer_value = '';



WITH fired AS (SELECT IF (ISNULL(AVG(correct)), 0, AVG(correct)) AS avg_fired
               FROM (SELECT COUNT(qaa.question_id) AS correct
                     FROM user u
                              JOIN enrollment e ON u.user_id = e.user_id
                              JOIN attempt a ON a.enrollment_id = e.enrollment_id
                              JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
                              JOIN quiz_question qq ON qaa.question_id = qq.question_id
                     WHERE u.state = 'fired'
                       AND a.start_date < '2025-01-01'
                       AND qaa.answer_value = qq.answer
                     GROUP BY a.attempt_id
               ) f
),
    active AS (SELECT AVG(correct) AS avg_active
               FROM (SELECT COUNT(qaa.question_id) AS correct
                     FROM user u
                              JOIN enrollment e ON u.user_id = e.user_id
                              JOIN attempt a ON a.enrollment_id = e.enrollment_id
                              JOIN quiz_attempt_answer qaa ON qaa.attempt_id = a.attempt_id
                              JOIN quiz_question qq ON qaa.question_id = qq.question_id
                     WHERE u.state = 'active'
                       AND a.start_date >= '2025-01-01'
                       AND qaa.answer_value = qq.answer
                     GROUP BY a.attempt_id
                    ) a
    )

SELECT f.avg_fired,
       a.avg_active,
       CASE
           WHEN f.avg_fired > a.avg_active
               THEN 'Уволенные пользователи лучше проходят квизы.'
           WHEN f.avg_fired < a.avg_active
               THEN 'Активные пользователи лучше проходят квизы.'
           ELSE 'Обе группы пользователей проходят квизы одинаково.'
        END AS comparision
FROM active a JOIN fired f;


# SELECT u.email, c.name, a.date
