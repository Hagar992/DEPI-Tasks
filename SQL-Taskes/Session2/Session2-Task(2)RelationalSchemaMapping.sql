Empoloyee(
		SSN INT PRIMARY KEY ,
		Fname VARCHAR(50) NOT NULL,
		Lname VARCHAR(50) NOT NULL,
		BirthDate Date,
		Gender VARCHAR(10),
		Department_ID INT NOT NULL,
		Supervisor_SSN INT ,
		FOREIGN KEY (Department_ID) REFERENCES Department(DNUM),
		FOREIGN KEY (Supervisor_SSN) REFERENCES Employee(SSN)
		)
Department(

		DNUM INT PRIMARY KEY,
		DName VARCHAR(50) NOT NULL,
		Location VARCHAR(50),
		Manager_SSN INT,
		Manager_Start_Date DATE,
		FOREIGN KEY (Manager_SSN) REFERENCES Employee(SSN)
         )
Project(
        PNumber INT PRIMARY KEY,
		PName VARCHAR(50),
		Location VARCHAR(50),
		department_ID INT NOT NULL,
		FOREIGN KEY (department_ID) REFERENCES Department(DNUM)
	    )
Dependent(
          Dep_Name VARCHAR(50),
		  Gender VARCHAR(50),
		  Birth_Date DATE,
		  Employee_SSN INT NOT NULL,
		  PRIMARY KEY (Dep_Name, Employee_SSN),
          FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
          )
Work_ON (
		  Employee_SSN INT,
		  Project_PNumber INT,
		  Hours FLOAT,
		  PRIMARY KEY (Employee_SSN, Project_PNumber),
		  FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN),
		  FOREIGN KEY (Project_PNumber) REFERENCES Project(PNumber)
         )
