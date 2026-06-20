import uuid
import random
from datetime import datetime, timedelta
import mysql.connector

HOST = "localhost"
PORT = 3306
USER = "root"
PASSWORD = "root"
DATABASE = "study"
SCALE = 10000

def generate_uuid():
    return uuid.uuid4()

def uuid_to_bytes(uuid_obj):
    return uuid_obj.bytes

def random_choice(list_items):
    return random.choice(list_items)

def random_int(min_val, max_val):
    return random.randint(min_val, max_val)

def random_date(start_date, end_date):
    start = datetime.fromisoformat(start_date)
    end = datetime.fromisoformat(end_date)
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    result_date = start + timedelta(seconds=random_seconds)
    return result_date.strftime('%Y-%m-%d %H:%M:%S')

STATUSES = ['active', 'active', 'active', 'unactive', 'fired']
COURSE_TYPES = ['video', 'video', 'audio', 'quiz', 'quiz']
QUIZ_STATUSES = ['published', 'published', 'draft', 'uploaded']
VIDEO_FORMATS = ['mp4', 'avi']
QUESTION_TYPES = ['multiple_choice', 'sequence']

def insert_batch(cursor, table_name, columns, data_rows, batch_size=500):
    if not data_rows:
        return
    
    placeholders = f"({','.join(['%s'] * len(columns))})"
    sql_query = f"INSERT INTO `{table_name}` ({','.join(f'`{col}`' for col in columns)}) VALUES {placeholders}"
    
    for i in range(0, len(data_rows), batch_size):
        batch = data_rows[i:i + batch_size]
        values = [tuple(row[col] for col in columns) for row in batch]
        cursor.executemany(sql_query, values)

connection = mysql.connector.connect(
    host=HOST,
    port=PORT,
    user=USER,
    password=PASSWORD,
    database=DATABASE
)
cursor = connection.cursor()
cursor.execute('SET FOREIGN_KEY_CHECKS=0')

users = []
for i in range(SCALE):
    user_data = {
        'user_id': uuid_to_bytes(generate_uuid()),
        'name': '' if i % 10 == 0 else f'User {i+1}',
        'email': f'user{i+1}@example.com',
        'state': random_choice(STATUSES)
    }
    users.append(user_data)

insert_batch(cursor, 'user', ['user_id', 'name', 'email', 'state'], users)

courses_count = max(10, SCALE // 5)
courses = []

for i in range(courses_count):
    course_uuid = generate_uuid()
    course_data = {
        'uuid': course_uuid,
        'name': f'Course {i+1}',
        'courseType': random_choice(COURSE_TYPES),
        'description': f'Description for Course {i+1}'
    }
    courses.append(course_data)

courses_for_insert = []
for course in courses:
    courses_for_insert.append({
        'course_id': uuid_to_bytes(course['uuid']),
        'name': course['name'],
        'courseType': course['courseType'],
        'description': course['description']
    })

insert_batch(cursor, 'course', ['course_id', 'name', 'courseType', 'description'], courses_for_insert)

videos = []
for course in courses:
    if course['courseType'] == 'video':
        video_data = {
            'video_id': uuid_to_bytes(course['uuid']),
            'source_url': f"https://example.com/video/{course['uuid']}.mp4",
            'format': random_choice(VIDEO_FORMATS),
            'duration': random_int(600, 10800),
            'size': random_int(50000, 2000000)
        }
        videos.append(video_data)

insert_batch(cursor, 'video', ['video_id', 'source_url', 'format', 'duration', 'size'], videos)

audios = []
for course in courses:
    if course['courseType'] == 'audio':
        audio_data = {
            'audio_id': uuid_to_bytes(course['uuid']),
            'source_url': f"https://example.com/audio/{course['uuid']}.mp3",
            'duration': random_int(600, 7200)
        }
        audios.append(audio_data)

insert_batch(cursor, 'audio', ['audio_id', 'source_url', 'duration'], audios)

quiz_courses = [c for c in courses if c['courseType'] == 'quiz']
quizzes = []

for course in quiz_courses:
    quiz_data = {
        'quiz_id': uuid_to_bytes(course['uuid']),
        'source_url': None,
        'weight': random_int(5, 15),
        'available_duration': random_choice([600, 900, 120, 1800, 300]),
        'state': random_choice(QUIZ_STATUSES)
    }
    quizzes.append(quiz_data)

insert_batch(cursor, 'quiz', ['quiz_id', 'source_url', 'weight', 'available_duration', 'state'], quizzes)

marks = []
for quiz in quizzes:
    grades = [
        (5, 90, 100),
        (4, 70, 89),
        (3, 50, 69),
        (2, 0, 49)
    ]
    for mark, min_score, max_score in grades:
        mark_data = {
            'mark_id': uuid_to_bytes(generate_uuid()),
            'quiz_id': quiz['quiz_id'],
            'mark': mark,
            'min_score': min_score,
            'max_score': max_score
        }
        marks.append(mark_data)

insert_batch(cursor, 'quiz_mark', ['mark_id', 'quiz_id', 'mark', 'min_score', 'max_score'], marks)

questions = []
multiple_choice_options = []
sequence_options = []

for quiz in quizzes:
    for question_num in range(5):
        question_uuid = generate_uuid()
        question_type = random_choice(QUESTION_TYPES)
        
        question_data = {
            'question_id': uuid_to_bytes(question_uuid),
            'quiz_id': quiz['quiz_id'],
            'text': f'Question {question_num+1} for quiz',
            'type': question_type,
            'order_index': question_num + 1
        }
        questions.append(question_data)
        
        if question_type == 'multiple_choice':
            correct_answer = random_int(1, 4)
            for option_num in range(1, 5):
                option_data = {
                    'question_id': uuid_to_bytes(question_uuid),
                    'option_number': option_num,
                    'value': f'Option {option_num}',
                    'is_correct': option_num == correct_answer
                }
                multiple_choice_options.append(option_data)
        else:
            for step_num in range(1, 5):
                option_data = {
                    'question_id': uuid_to_bytes(question_uuid),
                    'value': f'Step {step_num}',
                    'value_order': step_num
                }
                sequence_options.append(option_data)

insert_batch(cursor, 'quiz_question', ['question_id', 'quiz_id', 'text', 'type', 'order_index'], questions)
insert_batch(cursor, 'multiple_question_available_values', ['question_id', 'option_number', 'value', 'is_correct'], multiple_choice_options)
insert_batch(cursor, 'sequence_question_available_values', ['question_id', 'value', 'value_order'], sequence_options)

enrollments = []
used_pairs = set()

for user in users:
    courses_count_for_user = random_int(1, 5)
    if courses_count_for_user > len(courses):
        courses_count_for_user = len(courses)
    
    selected_courses = random.sample(courses, courses_count_for_user)
    
    for course in selected_courses:
        pair_key = (user['user_id'], course['uuid'])
        if pair_key in used_pairs:
            continue
        used_pairs.add(pair_key)
        
        start_date = random_date('2024-01-01', '2026-12-12')
        
        if random.random() > 0.4:
            end_date = random_date(start_date, '2027-01-01')
        else:
            end_date = None
        
        enrollment_data = {
            'enrollment_id': uuid_to_bytes(generate_uuid()),
            'user_id': user['user_id'],
            'course_id': uuid_to_bytes(course['uuid']),
            'start_date': start_date,
            'end_date': end_date
        }
        enrollments.append(enrollment_data)

insert_batch(cursor, 'enrollment', ['enrollment_id', 'user_id', 'course_id', 'start_date', 'end_date'], enrollments)

quiz_course_ids = {uuid_to_bytes(course['uuid']) for course in quiz_courses}
attempts = []

for enrollment in enrollments:
    if enrollment['course_id'] not in quiz_course_ids:
        continue
    
    attempts_count = random_int(1, 2)
    for _ in range(attempts_count):
        attempt_data = {
            'attempt_id': uuid_to_bytes(generate_uuid()),
            'enrollment_id': enrollment['enrollment_id'],
            'start_date': random_date('2023-06-01', '2026-05-01'),
            'duration': random_int(120, 3000),
            'score': random_int(0, 100)
        }
        attempts.append(attempt_data)

insert_batch(cursor, 'attempt', ['attempt_id', 'enrollment_id', 'start_date', 'duration', 'score'], attempts)

question_by_quiz = {}
for question in questions:
    quiz_id = question['quiz_id']
    if quiz_id not in question_by_quiz:
        question_by_quiz[quiz_id] = []
    question_by_quiz[quiz_id].append(question)

multiple_choice_by_question = {}
for option in multiple_choice_options:
    question_id = option['question_id']
    if question_id not in multiple_choice_by_question:
        multiple_choice_by_question[question_id] = []
    multiple_choice_by_question[question_id].append(option)

sequence_by_question = {}
for option in sequence_options:
    question_id = option['question_id']
    if question_id not in sequence_by_question:
        sequence_by_question[question_id] = []
    sequence_by_question[question_id].append(option)

enrollment_by_id = {enrollment['enrollment_id']: enrollment for enrollment in enrollments}

answers = []
for attempt in attempts:
    enrollment = enrollment_by_id[attempt['enrollment_id']]
    quiz_questions = question_by_quiz.get(enrollment['course_id'], [])
    
    if random.random() < 0.2 and len(quiz_questions) > 0:
        quiz_questions = quiz_questions[:-1]
    
    for question in quiz_questions:
        if question['type'] == 'multiple_choice':
            options = multiple_choice_by_question.get(question['question_id'], [])
            is_correct = random.random() > 0.5
            chosen_option = None
            
            for option in options:
                if option['is_correct'] == is_correct:
                    chosen_option = option
                    break
            
            if not chosen_option and options:
                chosen_option = options[0]
            
            if chosen_option:
                answer_data = {
                    'attempt_id': attempt['attempt_id'],
                    'question_id': question['question_id'],
                    'answer_value': chosen_option['value'],
                    'answer_order': None
                }
                answers.append(answer_data)
                
        else:
            sequence_values = sequence_by_question.get(question['question_id'], [])
            shuffled_values = random.sample(sequence_values, len(sequence_values))
            
            for order, value in enumerate(shuffled_values, 1):
                answer_data = {
                    'attempt_id': attempt['attempt_id'],
                    'question_id': question['question_id'],
                    'answer_value': value['value'],
                    'answer_order': order
                }
                answers.append(answer_data)

insert_batch(cursor, 'quiz_attempt_answer', ['attempt_id', 'question_id', 'answer_value', 'answer_order'], answers)

cursor.execute('SET FOREIGN_KEY_CHECKS=1')
connection.commit()
cursor.close()
connection.close()

print('ok')