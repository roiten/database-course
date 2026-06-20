CREATE DATABASE IF NOT EXISTS json_example;
USE json_example;

CREATE TABLE profile
(
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    properties JSON NOT NULL
);

INSERT INTO profile (properties)
VALUES
       ('{
          "first_name": "Иван",
          "last_name": "Тарасов",
          "login": "ivan-tarasov",
          "organisation": "beer-factory",
          "rate": 1.45,
          "experience": 3
       }'),
       ('{
         "first_name": "Иван",
         "last_name": "Березин",
         "login": "ivan-beresin",
         "phones": ["+79275678887"],
         "organisation": "university",
         "grade": "student",
         "birth-date": "22.02.2006"
       }'),
       ('{
         "first_name": "Андрей",
         "last_name": "Плотиков",
         "login": "a-plotikov",
         "organisation": "building",
         "phones": ["+79298761328", "367698"],
         "rate": 1,
         "post": "brickman"
       }'),
       ('{
         "first_name": "Nataly",
         "last_name": "Zikratova",
         "login": "morskaya-pehota",
         "organisation": "university",
         "phones": ["+79275678785"],
         "grade": "teacher",
         "rate": 0.5,
         "subjects": ["math", "phisycs", "public-speaking"]
       }'),
       ('{
         "first_name": "Artur",
         "last_name": "Mikaelyan",
         "login": "a-mikaelyan",
         "organisation": "beer-factory",
         "rate": 1.2,
         "experience": 10,
         "achievements": {
           "important": ["Генерал майонез"],
           "unimportant": ["Армянский кетчуп", "Коньяк"]
         }
       }'),
       ('{
         "first_name": "Дмитрий",
         "last_name": "Губерниев",
         "login": "dguberniev",
         "phones": ["+79395678887"],
         "organisation": "building",
         "rate": 1,
         "post": "speaker"
       }'),
       ('{
         "first_name": "Mikhail",
         "last_name": "Chulkov",
         "login": "mr-nigger",
         "phones": ["+79175619027"],
         "organisation": "university",
         "grade": "student",
         "birth-date": "18.03.2006",
         "course": 2
       }'),
       ('{
         "first_name": "Иван",
         "last_name": "Тарасов",
         "login": "ivan-tarasov",
         "organisation": "building",
         "rate": 3,
         "post": "supervisor"
       }'),
       ('{
         "first_name": "Tayler",
         "last_name": "Derden",
         "login": "tderden",
         "organisation": "university",
         "grade": "teacher",
         "rate": 1.5,
         "subjects": ["filming", "service", "public-speaking"]
       }'),
       ('{
         "first_name": "Valery",
         "last_name": "Rimin",
         "login": "rimin",
         "organisation": "beer-factory",
         "rate": 1.4,
         "experience": 30,
         "post": "tester",
         "achievements": {
           "important": ["Дегустатор года", "Мистер-пресс 2011"],
           "unimportant": ["Курсы переквалификации мастеров плиточников", "Матёрый танкист 2016"]
         }
       }');



SELECT profile_id, properties->>'$.last_name' AS lastname
FROM profile
WHERE properties->>'$.organisation' = 'building';

UPDATE profile
SET properties = JSON_REPLACE(properties, '$.first_name', 'Ivan')
WHERE properties->>'$.first_name' = 'Иван';

SELECT profile_id, properties->>'$.first_name' AS firstname, properties->>'$.last_name' AS lastname
FROM profile
WHERE properties->>'$.first_name' = 'Ivan';

EXPLAIN SELECT profile_id, properties->>'$.login' AS login
                FROM profile
                WHERE properties->>'$.login' = 'ivan-tarasov' ; -- LIKE '%-%';


CREATE INDEX `login_idx` ON `profile` ((CAST(properties ->>'$.login' AS CHAR(100))));


UPDATE profile
SET properties = IF(
    properties ->'$.phones' IS NULL,
    JSON_SET(properties, '$.phones', JSON_ARRAY('+78004531937')),
    JSON_ARRAY_APPEND(properties, '$.phones', '+78004531937')
)
WHERE profile.properties->>'$.organisation' = 'beer-factory';

UPDATE profile
SET properties = IF(
    properties ->'$.phones' IS NULL,
    JSON_SET(properties, '$.phones', JSON_ARRAY('+78086742322')),
    JSON_ARRAY_APPEND(properties, '$.phones', '+78086742322')
)
WHERE profile.properties->>'$.organisation' = 'university';


SELECT properties ->> '$.phones[last]' AS phone
FROM profile
WHERE profile_id = 1;

DROP FUNCTION GetUsersIdByPhone;

CREATE FUNCTION GetUsersIdByPhone(phone VARCHAR(18))
RETURNS JSON
READS SQL DATA
BEGIN
    DECLARE result JSON;

    SELECT JSON_ARRAYAGG(profile_id)
    INTO result
    FROM profile
    WHERE JSON_CONTAINS(properties ->'$.phones', JSON_QUOTE(phone));

    RETURN result;
END;


SELECT GetUsersIdByPhone('+78004531937');
