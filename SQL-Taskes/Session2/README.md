Session 2 Assignment
Assignment

Task 1: ER Diagram Design#
Create a complete Entity-Relationship Diagram (ERD)

The company has a number of employees; each employee has SSN, Birth Date, Gender and Name which represented as Fname and Lname.
The company has a set of departments; each department has a set of attributes DName, DNUM (unique) and locations.
Employees work in several projects; each project has Pname, PNumber as an identifier, Location City.
Each employee may have a set of dependents; each dependent has Dependent Name (unique), Gender and Birthdate. Note: if the employee left the company no needs to store his dependents info.
For each Department, there is always one employee assigned to manage that Department and each manager has a hiring Date.
Department may have employees but employee must work on Only One department.
Each department may have a set of projects and each project must assigned to one department.
Employees work in several projects and each project has several employees and each employee has a number of working hours in each project.
Each employee has a supervisor.
_________________________________________________________________________
Task 2: Relational Schema Mapping#
Convert your ER diagram to relational schema using the mapping rules

Provide the complete relational schema with:

Table names and column names
Primary keys (PK)
Foreign keys (FK)
Data types for each column
Constraints (NOT NULL, UNIQUE, etc.)
____________________________________________________________________________
Task 3: SQL Implementation#
Implement the following SQL statements:

Create the EMPLOYEE table with all constraints
Create the DEPARTMENT table with proper relationships
Create the PROJECT table
Add foreign key constraints between tables
Insert sample data into EMPLOYEE table (at least 5 employees)
Insert sample data into DEPARTMENT table (at least 3 departments)
Update an employee's department
Delete a dependent record
Retrieve all employees working in a specific department
Find all employees and their project assignments with working hours
_________________________________________________________________________
Additional Notes#
Use proper SQL Server syntax for all queries
Include sample data that demonstrates all relationships
Test your queries to ensure they work correctly
Consider performance implications in your design
Document any assumptions you make about the requirements
