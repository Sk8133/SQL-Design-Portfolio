-- ✅ Personal Finance Tracker — Final SQL
-- Author: Anjali Shinde
-- Date: 21 July 2025

-- ==========================================
-- ✅ 1️⃣ Create Database & Use it
-- ==========================================

CREATE DATABASE IF NOT EXISTS PersonalFinanceTracker;
USE PersonalFinanceTracker;

-- ==========================================
-- ✅ 2️⃣ Drop Tables if They Exist
-- ==========================================

DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Income;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Users;

-- ==========================================
-- ✅ 3️⃣ Create Tables
-- ==========================================

-- Users table
CREATE TABLE Users (
  UserID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(50),
  Email VARCHAR(100) UNIQUE
);

-- Categories table
CREATE TABLE Categories (
  CategoryID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(50) UNIQUE
);

-- Income table
CREATE TABLE Income (
  IncomeID INT AUTO_INCREMENT PRIMARY KEY,
  UserID INT,
  Amount DECIMAL(10,2),
  IncomeDate DATE,
  Description VARCHAR(100),
  FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Expenses table
CREATE TABLE Expenses (
  ExpenseID INT AUTO_INCREMENT PRIMARY KEY,
  UserID INT,
  CategoryID INT,
  Amount DECIMAL(10,2),
  ExpenseDate DATE,
  Description VARCHAR(100),
  FOREIGN KEY (UserID) REFERENCES Users(UserID),
  FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- ==========================================
-- ✅ 4️⃣ Insert Sample Data
-- ==========================================

-- Insert User
INSERT INTO Users (Name, Email)
VALUES ('Anjali Shinde', 'anjali.shinde@example.com');

-- Insert Categories
INSERT INTO Categories (Name)
VALUES ('Groceries'), ('Rent'), ('Travel'), ('Entertainment'), ('Utilities');

-- Insert Income
INSERT INTO Income (UserID, Amount, IncomeDate, Description)
VALUES
(1, 50000.00, '2025-07-01', 'Monthly Salary'),
(1, 5000.00, '2025-07-15', 'Freelance Project');

-- Insert Expenses
INSERT INTO Expenses (UserID, CategoryID, Amount, ExpenseDate, Description)
VALUES
(1, 1, 2500.00, '2025-07-02', 'Supermarket shopping'),
(1, 2, 15000.00, '2025-07-03', 'Monthly Rent'),
(1, 3, 3000.00, '2025-07-05', 'Weekend trip'),
(1, 1, 1800.00, '2025-07-10', 'Grocery top-up'),
(1, 4, 2000.00, '2025-07-12', 'Movie & dinner'),
(1, 5, 1200.00, '2025-07-14', 'Electricity bill');

-- ==========================================
-- ✅ 5️⃣ Monthly Expense Summary
-- ==========================================

SELECT 
  DATE_FORMAT(ExpenseDate, '%Y-%m') AS Month,
  SUM(Amount) AS TotalExpenses
FROM Expenses
WHERE UserID = 1
GROUP BY Month;

-- ==========================================
-- ✅ 6️⃣ Top Spending Categories
-- ==========================================

SELECT 
  C.Name AS Category,
  SUM(E.Amount) AS TotalSpent
FROM Expenses E
JOIN Categories C ON E.CategoryID = C.CategoryID
WHERE UserID = 1
GROUP BY C.Name
ORDER BY TotalSpent DESC;

-- ==========================================
-- ✅ 7️⃣ Balance Left
-- ==========================================

SELECT 
  (SELECT SUM(Amount) FROM Income WHERE UserID = 1) -
  (SELECT SUM(Amount) FROM Expenses WHERE UserID = 1) AS BalanceLeft;

-- ==========================================
-- ✅ 8️⃣ Category-wise Insights
-- ==========================================

SELECT 
  C.Name AS Category,
  COUNT(E.ExpenseID) AS NumberOfExpenses,
  SUM(E.Amount) AS TotalSpent
FROM Expenses E
JOIN Categories C ON E.CategoryID = C.CategoryID
WHERE UserID = 1
GROUP BY C.Name;

-- ==========================================
-- ✅ 9️⃣ Create View: User Dashboard
-- ==========================================

CREATE VIEW UserDashboard AS
SELECT 
  U.Name AS UserName,
  E.ExpenseDate,
  C.Name AS Category,
  E.Amount,
  E.Description
FROM Expenses E
JOIN Users U ON E.UserID = U.UserID
JOIN Categories C ON E.CategoryID = C.CategoryID
WHERE U.UserID = 1;

-- Test View
SELECT * FROM UserDashboard;

-- ✅ END OF FILE
