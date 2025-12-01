DROP SCHEMA IF EXISTS practical_test_2_Hulevich;
CREATE SCHEMA practical_test_2_Hulevich;
USE practical_test_2_Hulevich;

DROP TABLE IF EXISTS student, teacher, grade;

CREATE TABLE teacher
(
    teacher_id int auto_increment primary key,
    teacher_name varchar(20) not null ,
    teacher_cathedra char(5) not null
);

CREATE TABLE student
(
    student_id int auto_increment primary key,
    student_name varchar(20) not null,
    student_groupe char(5) not null,
    student_teacher_id int,
    FOREIGN KEY (student_teacher_id) REFERENCES teacher(teacher_id)
);

CREATE TABLE grade
(
    grade_id int auto_increment primary key,
    grade_teacher_id int,
    grade_student_id int,
    grade_date date,
    grade int,
    FOREIGN KEY (grade_teacher_id) REFERENCES teacher(teacher_id),
    FOREIGN KEY (grade_student_id) REFERENCES student(student_id)

);
INSERT teacher(teacher_name, teacher_cathedra)
    VALUES ('Ньютон', 'K-1'),
           ('Эйнштейн', 'K-1'),
           ('Паскаль', 'K-2'),
           ('Фарадей', 'K-2'),
           ('Тесла', 'K-2');

INSERT student(student_name, student_groupe, student_teacher_id)
    VALUES  ('Незнайка', 'G-1', 1),
            ('Дровосек', 'G-2', 3),
            ('Чебурашка', 'G-1', 2),
            ('Дракула', 'G-2', NULL),
            ('Коля', 'G-3', 4),
            ('Юля', 'G-', 4);

INSERT grade(grade_teacher_id, grade_student_id, grade_date, grade)
    VALUES (1, 1, '2025-01-11', 7),
            (3, 1, '2025-01-12', 5),
            (2, 2, '2025-01-13', 6),
            (5, 2, '2025-01-16', 3),
            (4, 3, '2025-01-17', 4),
            (2, 3, '2025-01-19', 7),
            (3, 4, '2025-01-12', 9),
            (4, 4, '2025-01-10', 3),
            (5, 5, '2025-01-15', 5),
            (1, 5, '2025-01-14', 4);


# ________________________ Практическая работа №2 ___________________________
-- Получить фамилии дипломников с указанием руководителей
SELECT student.student_name AS 'ФИО Студента', teacher_name AS 'ФИО Руководителя'
    FROM student
    INNER JOIN teacher t on student.student_teacher_id = t.teacher_id;

-- Оценки студентов группы Г-2 с указанием фамилий студентов и преподавателей.
SELECT student_name, teacher_name, grade.grade
    FROM grade
    INNER JOIN student s on grade.grade_student_id = s.student_id
    INNER JOIN teacher t on grade.grade_teacher_id = t.teacher_id
    WHERE student_groupe = 'G-2';

-- Фамилии руководителей дипломов в группах Г-1 и Г-2.
    SELECT teacher.teacher_name 'Руководитель диплома', student_groupe 'Группа'
        FROM teacher
        INNER JOIN student s on teacher.teacher_id = s.student_teacher_id
        WHERE student_groupe IN ('G-1', 'G-2');

-- Получить оценки с указанием фамилий студентов.
SELECT s.student_name, grade.grade
    FROM grade
    LEFT JOIN student s on grade.grade_student_id = s.student_id;

-- Получить фамилии всех студентов. Для дипломников указать руководителей
SELECT student.student_name AS 'ФИО Студента',
       CASE
           WHEN student_teacher_id IS NOT NULL
                THEN teacher_name
           ELSE 'Нет руководителя'
       END 'ФИО Руководителя'
FROM student
         LEFT JOIN teacher t on student.student_teacher_id = t.teacher_id;

-- Вывести фамилии студентов которые не сдавали экзамен.
SELECT student.student_name AS 'ФИО Студента который не сдавал экзамен'
    FROM student
    LEFT JOIN grade g on student.student_id = g.grade_student_id
    WHERE grade_student_id IS NULL;

-- Получить количество дипломников
SELECT  count(*) as 'Количество дипломников'
    FROM student
    WHERE student_teacher_id IS NOT NULL;

-- Получить ФИО студентов и их средние балы.
SELECT student.student_name 'Имя студента', round(avg(grade),1) 'Средний бал'
    FROM student
    INNER JOIN grade g on student.student_id = g.grade_student_id
    GROUP BY student_name;

-- Получить сведения об оценках отсортированные по коду студента и по убыванию оценки.
SELECT student.student_name, grade
    FROM student
    LEFT JOIN grade g on student.student_id = g.grade_student_id
    ORDER BY student_id, grade DESC;

-- Получить список дипломников у каждого преподавателя.
SELECT teacher.teacher_name, student_name
    FROM teacher
    LEFT JOIN grade g on teacher.teacher_id = g.grade_teacher_id
    LEFT JOIN student s on g.grade_student_id = s.student_id;

-- Получить количество положительных оценок (>=4) у дипломников каждой кафедры в названии которой есть буква 'К'.
SELECT teacher.teacher_cathedra 'Кафедра', count(grade) 'Количество положительных оценок'
    FROM teacher
    LEFT JOIN grade g on teacher.teacher_id = g.grade_teacher_id
    WHERE grade >=4 AND teacher_cathedra LIKE '%K%'
    GROUP BY teacher_cathedra;

# -- Получить пары всех студентов обучающихся в одной и той же группе.
SELECT s1.student_groupe 'Группа',
       s1.student_name 'Первый студент',
       s2.student_name 'Второй студент'
    FROM student s1
    JOIN student s2 on s1.student_groupe = s2.student_groupe
    WHERE s1.student_id < s2.student_id