-- Create the database, the table and add the relevant rows of information

CREATE DATABASE appdb;

-- Then use the context of the new database

USE appdb;

-- Create a table in the database

CREATE TABLE Course
(
   CourseID int,   
   CourseName varchar(1000),
   Rating numeric(2,1)
);

-- Insert rows of data into the table

INSERT INTO Course(CourseID,CourseName,Rating) VALUES(1, 'Docker and Kubernetes',4.5);

INSERT INTO Course(CourseID,CourseName,Rating) VALUES(2,'AZ-204 Azure Developer',4.6);

INSERT INTO Course(CourseID,CourseName,Rating) VALUES(3,'AZ-104 Administrator',4.7);

-- Also create a new user and grant options accordingly.

CREATE USER 'appusr'@'%' IDENTIFIED WITH mysql_native_password BY 'Microsoft@123';

GRANT SELECT on *.* TO 'appusr'@'%' WITH GRANT OPTION;


     	