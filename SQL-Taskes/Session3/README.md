# Session 3 Assignment - DDL Practice + SQL Queries on StoreDB
## Assignment

### Task 1 – Create the DDL (Data Definition Language) for Company ERD#
### Design a full database schema for the following scenario using SQL Server (DDL):

## 💡 Notes#
- An employee works for only one department
- A department is managed by one employee
- An employee can work on many projects (M:N)
- Projects must belong to one department
- Employees can have many dependents
- Deleting an employee should delete their dependents automatically
### Constraints:#
Including the following for each table:

- - Required constraints:

- PRIMARY KEY constraints on all tables
- FOREIGN KEY constraints with appropriate ON DELETE and ON UPDATE actions
- NOT NULL constraints on required fields
- UNIQUE constraints where applicable
- DEFAULT values for relevant columns
- CHECK constraints for data validation (e.g. gender must be 'M' or 'F')
- Additional requirements:

- - Demonstrate ALTER TABLE usage by:
- Adding a new column
- Adding a FOREIGN KEY constraint
- Modifying a column's data type
- Dropping an existing constraint
- Include sample data insertion
____________________________________________________________________
### Task 2 – SQL Queries on StoreDB#
### Use the provided StoreDB database to perform the following queries:

1-List all products with list price greater than 1000
Get customers from "CA" or "NY" states
Retrieve all orders placed in 2023
Show customers whose emails end with @gmail.com
Show all inactive staff
List top 5 most expensive products
Show latest 10 orders sorted by date
Retrieve the first 3 customers alphabetically by last name
Find customers who did not provide a phone number
Show all staff who have a manager assigned
Count number of products in each category
Count number of customers in each state
Get average list price of products per brand
Show number of orders per staff
Find customers who made more than 2 orders
Products priced between 500 and 1500
Customers in cities starting with "S"
Orders with order_status either 2 or 4
Products from category_id IN (1, 2, 3)
Staff working in store_id = 1 OR without phone number
Submission Instructions#
Submit a .sql file with all queries properly commented
Use readable aliasing and formatting
Test your queries before submission
