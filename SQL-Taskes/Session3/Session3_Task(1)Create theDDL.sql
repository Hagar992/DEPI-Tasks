CREATE DATABASE CompanyDB;
USE CompanyDB;

Create Table Department(
                        DNUM INT PRIMARY KEY,
                        DName VARCHAR(50) NOT NULL,
                        Location VARCHAR(50),
                        Manager_SSN INT,
                        Manager_Start_Date Date
                        );

Create Table Employee(
                       SSN INT PRIMARY KEY,
                       FName VARCHAR(50) NOT NULL,
                       LName VARCHAR(50) NOT NULL,
                       Gender char(1) CHECK (Gender IN ('M','F')),
                       Birth_Date DATE,
                       Department_ID INT NOT NULL,
                       Supervisor_SSN INT,
                       Salary DECIMAL(10,2) DEFAULT 8000,
                       FOREIGN KEY (Department_ID) REFERENCES Department(DNUM)
                                    ON DELETE NO ACTION
                                    ON UPDATE CASCADE,
                       FOREIGN KEY(Supervisor_SSN) REFERENCES Employee(SSN)
                                    ON DELETE NO ACTION
                       );


ALTER TABLE Department 
      ADD CONSTRAINT FK_Manager_SSN FOREIGN KEY (Manager_SSN) REFERENCES Employee(SSN)
                     ON DELETE NO ACTION
                     ON UPDATE NO ACTION;

CREATE TABLE Project(
                      PNumber INT PRIMARY KEY,
                      PName VARCHAR(100) NOT NULL,
                      Location VARCHAR(100),
                      Department_ID INT NOT NULL,
                      FOREIGN KEY (Department_ID) REFERENCES Department(DNUM)
                            
                     );

CREATE TABLE Works_On (
                        Employee_SSN INT,
                        Project_PNumber INT,
                        Hours FLOAT CHECK (Hours >= 0),
                        PRIMARY KEY (Employee_SSN, Project_PNumber),
                        FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
                        FOREIGN KEY (Project_PNumber) REFERENCES Project(PNumber)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
                      );

CREATE TABLE Dependent (
                        Dep_Name VARCHAR(50),
                        Gender CHAR(1) CHECK (Gender IN ('M','F')),
                        BirthDate DATE,
                        Employee_SSN INT,
                        PRIMARY KEY (Dep_Name, Employee_SSN),
                        FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
                    );

ALTER TABLE Project
ADD Budget DECIMAL(12,2) DEFAULT 100000;

ALTER TABLE Department
ALTER COLUMN DName VARCHAR(100);


INSERT INTO Department (DNUM, DName, Location)
VALUES
(1, 'HR', 'Cairo'),
(2, 'IT', 'Alexandria'),
(3, 'Finance', 'Giza');

INSERT INTO Employee (SSN, FName, LName, Gender, Birth_Date, Department_ID, Supervisor_SSN)
VALUES
(1001, 'Ali', 'Hassan', 'M', '1990-05-10', 1, NULL),
(1002, 'Sara', 'Ibrahim', 'F', '1993-07-15', 1, 1001),
(1003, 'Omar', 'Kamal', 'M', '1988-03-22', 2, 1001),
(1004, 'Nour', 'Mahmoud', 'F', '1995-11-05', 2, 1003),
(1005, 'Hany', 'Ali', 'M', '1992-01-18', 3, 1001);

UPDATE Department SET Manager_SSN = 1001, Manager_Start_Date = '2020-01-01' WHERE DNUM = 1;


INSERT INTO Project (PNumber, PName, Location, Department_ID)
VALUES
(501, 'Payroll System', 'Cairo', 3, 150000),
(502, 'Recruitment Portal', 'Alexandria', 1, 120000);




--Test
SELECT * FROM Works_On;

INSERT INTO Works_On (Employee_SSN, Project_PNumber, Hours)
VALUES
(1001, 501, 10.5),
(1002, 502, 8.0),
(1003, 501, 7.5),
(1004, 502, 6.0);


INSERT INTO Dependent (Dep_Name, Gender, BirthDate, Employee_SSN)
VALUES
('Lina', 'F', '2018-06-10', 1001),
('Youssef', 'M', '2019-09-25', 1002);












