DROP SCHEMA IF EXISTS practical_test_1_Hulevich;
CREATE SCHEMA practical_test_1_Hulevich;
USE practical_test_1_Hulevich;

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
            ('Коля', 'G-3', 4);

INSERT grade(grade_teacher_id, grade_student_id, grade_date, grade)
    VALUES (1, 1, '2025-01-11', 7),
            (3, 1, '2025-01-12', 5),
            (2, 2, '2025-01-13', 6),
            (5, 2, '2025-01-16', 6),
            (4, 3, '2025-01-17', 4),
            (2, 3, '2025-01-19', 7),
            (3, 4, '2025-01-12', 9),
            (4, 4, '2025-01-10', 6),
            (5, 5, '2025-01-15', 5),
            (1, 5, '2025-01-14', 4);

# Положительные оценки (более 4) студентов полученные с 15 по 20 января.
# Выводит имя студена, дату оценки и оценку.
SELECT student.student_name AS 'Имя студента', grade.grade_date AS 'Дата', grade.grade AS 'Оценка'
    FROM grade
    INNER JOIN student
        ON grade.grade_student_id = student.student_id
    WHERE grade > 4 and grade_date BETWEEN '2025-01-15' AND '2025-01-20';

# Положительные оценки (более 4) студентов с id 1 и 2
SELECT student.student_name AS 'Имя студента', student.student_id AS 'ID студента', grade.grade AS 'Оценка'
    FROM grade
    INNER JOIN student
        ON grade.grade_student_id = student.student_id
    WHERE grade > 4 AND (student_id BETWEEN 1 AND 2);

# Все студенты кроме групп G-1 и G-2
SELECT  student.student_name AS 'Имя студента', student.student_groupe AS 'Группа'
     FROM student
     WHERE student_groupe <> 'G-1' AND student_groupe <> 'G-2' ;


select concat(`student_groupe`, ' ', `student_name`) from student;