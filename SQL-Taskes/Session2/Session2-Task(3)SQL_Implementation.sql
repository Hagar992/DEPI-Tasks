CREATE TABLE Department (
					  DNUM INT PRIMARY KEY,
					  DName VARCHAR(100)  NOT NULL,
					  Location VARCHAR(100),
					  Manager_SSN INT ,
					  Manager_Start_Date DATE,
					);
CREATE TABLE Employee (
					  SSN INT PRIMARY KEY,
					  Fname VARCHAR(50) NOT NULL,
					  Lname VARCHAR(50) NOT NULL,
					  BirthDate DATE,
					  Gender VARCHAR(10),
					  Department_ID INT NOT NULL,
					  Supervisor_SSN INT NULL,
					  FOREIGN KEY (Department_ID) REFERENCES Department(DNUM),
					  FOREIGN KEY (Supervisor_SSN) REFERENCES Employee(SSN)
					);
ALTER TABLE Department
ADD CONSTRAINT fk_manager FOREIGN KEY (Manager_SSN) REFERENCES Employee(SSN);

CREATE TABLE Project (
					  PNumber INT PRIMARY KEY,
					  PName VARCHAR(100),
					  Location VARCHAR(100),
					  Department_ID INT NOT NULL,
					  FOREIGN KEY (Department_ID) REFERENCES Department(DNUM)
					);
CREATE TABLE DEPENDENT (
					  Dep_Name VARCHAR(50),
					  Gender VARCHAR(10),
					  BirthDate DATE,
					  Employee_SSN INT NOT NULL,
					  PRIMARY KEY (Dep_Name, Employee_SSN),
					  FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
					);
CREATE TABLE Work_ON (
					  Employee_SSN INT,
					  Project_PNumber INT,
					  Hours FLOAT,
					  PRIMARY KEY (Employee_SSN, Project_PNumber),
					  FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN),
					  FOREIGN KEY (Project_PNumber) REFERENCES Project(PNumber)
					);

INSERT INTO Department(DNUM, DName, Location, Manager_SSN, Manager_Start_Date)
VALUES
(1, 'HR', 'Cairo', NULL, NULL),
(2, 'IT', 'Alexandria', NULL, NULL),
(3, 'Finance', 'Giza', NULL, NULL);

INSERT INTO Employee(SSN, Fname, Lname, BirthDate, Gender, Department_ID, Supervisor_SSN)
VALUES
(1001, 'Ali', 'Hassan', '1990-05-10', 'M', 1, NULL),
(1002, 'Sara', 'Ibrahim', '1993-07-15', 'F', 1, 1001),
(1003, 'Omar', 'Kamal', '1988-03-22', 'M', 2, 1001),
(1004, 'Nour', 'Mahmoud', '1995-11-05', 'F', 2, 1003),
(1005, 'Hany', 'Ali', '1992-01-18', 'M', 3, 1001);

UPDATE Department SET Manager_SSN = 1001, Manager_Start_Date = '2020-01-01' WHERE DNUM = 1;

INSERT INTO Project(PNumber, PName, Location, Department_ID)
VALUES
(501, 'Payroll System', 'Cairo', 3),
(502, 'Recruitment Portal', 'Alexandria', 1);

INSERT INTO Work_ON (Employee_SSN, Project_PNumber, Hours)
VALUES
(1001, 501, 10.5),
(1002, 502, 8.0),
(1003, 501, 7.5),
(1004, 502, 6.0);

INSERT INTO DEPENDENT (Dep_Name, Gender, BirthDate, Employee_SSN)
VALUES
('Lina', 'F', '2018-06-10', 1001),
('Youssef', 'M', '2019-09-25', 1002);

UPDATE Employee SET Department_ID = 2 WHERE SSN = 1005;

DELETE FROM DEPENDENT WHERE Dep_Name = 'Lina' AND Employee_SSN = 1001;

SELECT * FROM Employee
WHERE Department_ID = (SELECT DNUM FROM Department WHERE DName = 'IT');

SELECT E.Fname, E.Lname, P.PName, W.Hours
FROM Employee E
JOIN Work_ON W ON E.SSN = W.Employee_SSN
JOIN Project P ON P.PNumber = W.Project_PNumber;


