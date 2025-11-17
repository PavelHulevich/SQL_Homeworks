DROP SCHEMA IF EXISTS title_position;
CREATE SCHEMA title_position;
USE title_position;

CREATE TABLE gender
(
    id_gender int auto_increment primary key,
    gender_name varchar(20) unique
);

CREATE TABLE person
(
    id_person int auto_increment primary key,
    first_name varchar(20) not null,
    last_name varchar(40) not null,
    person_gender int,
    FOREIGN KEY (person_gender) REFERENCES gender(id_gender)
);

CREATE TABLE title
(
    id_title int auto_increment primary key,
    title_name varchar(20) unique
);

CREATE TABLE position
(
    id_position int auto_increment primary key,
    position_name varchar(20) unique
);
