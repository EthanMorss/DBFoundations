--*************************************************************************--
-- Title: Assignment06
-- Author: Ethan Morss
-- Desc: This file demonstrates how to use Views
-- Change Log: 
-- 2021-02-18, Ethan Morss Wored on Problems 1,2,3,4,5,6,7,8,9,10
-- 2021-02-22 Changed 8 and 10
-- 2021-02-18,Ethan Morss,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_EMorss')
	 Begin 
	  Alter Database [Assignment06DB_EMorss] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_EMorss;
	 End
	Create Database Assignment06DB_EMorss;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_EMorss;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create
View vCategories
WITH SCHEMABINDING
AS
Select CategoryID, CategoryName
From dbo.Categories;
Go

Create
View vProducts
WITH SCHEMABINDING
AS
Select ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products;
Go

Create
View vEmployees
WITH SCHEMABINDING
AS
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees;
Go

Create
View vInventories
WITH SCHEMABINDING
AS
Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
From dbo.Inventories;
Go

Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public;
Go

Deny Select On Products to Public;
Grant Select On vProducts to Public;
Go

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;
Go

Deny Select On Categories to Public;
Grant Select On vCategories to Public;
Go


-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create
View vCategoryProductNamesPrices
AS
Select Top 10000 CategoryName, ProductName, UnitPrice
From dbo.Categories as C Inner Join dbo.Products as P
On C.CategoryID = P.CategoryID
Order By CategoryName, ProductName
Go


Select * From vCategoryProductNamesPrices


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create
View vProductNameInventoryDateCount
As
Select Top 10000 ProductName, Count, InventoryDate
From Products as P Inner Join Inventories as I
On P.ProductID = I.ProductID
Order By ProductName, InventoryDate, Count
Go

Select * From vProductNameInventoryDateCount

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- First Draft
--Create
--View vInvetoryDateEmployee
--AS
--Select Top 3 InventoryDate, [EmployeeName] = EmployeeFirstName +' '+ EmployeeLastName
--From Inventories as I Inner Join Employees as E
--On I.EmployeeID = E.EmployeeID
--Order By InventoryDate;
--Go


Create
View vInventoryDateEmployee
AS
Select Distinct InventoryDate, [EmployeeName] = EmployeeFirstName +' '+ EmployeeLastName
From Inventories as I Inner Join Employees as E
On I.EmployeeID = E.EmployeeID;
Go

Select * From vInventoryDateEmployee

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!



Create
View vCategoryByProductByDateByCount
As
Select Top 10000 CategoryName, ProductName, InventoryDate, Count
From Categories as C Inner Join Products as P
On C.CategoryID = P.CategoryID
Left Outer Join Inventories as I
On P.ProductID = I.ProductID
Order By CategoryName, ProductName, InventoryDate, Count;
Go

Select * From vCategoryByProductByDateByCount


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54



-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create
View vCategoryByProductByInventoryByCountByEmployee
As
Select Top 10000 CategoryName, ProductName, InventoryDate, Count, [Employee Name]=EmployeeFirstName +' '+ EmployeeLastName
From Categories as C Inner Join Products as P
On C.CategoryID = P.CategoryID
Inner Join Inventories as I
On I.InventoryID = P.ProductId
Inner Join Employees as E
On E.EmployeeID = I.EmployeeID
Order By 1,2,3,4;
Go

Select * From vCategoryByProductByInventoryByCountByEmployee


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

-- Second Draft -- Realized We need to work from views not tables

Create
View vInventoriesForChaiAndChangByEmployees
As
Select Top 100 CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = vE.EmployeeFirstName +' '+ vE.EmployeeLastName
From vCategories as vC
inner Join vProducts as vP
on vC.CategoryID = vP.CategoryID
inner join vInventories as vI
on vI.ProductID = vP.ProductID
inner join vEmployees as vE
on vE.EmployeeID = vI.EmployeeID
Where vP.ProductName IN 
	(Select vP.ProductName From vProducts Where vP.ProductName IN ('Chai','Chang'))
Order By InventoryDate, CategoryName, ProductName;;
go

Select * From vInventoriesForChaiAndChangByEmployees

-- First Draft -- Joined Tabels.  SHould have Joined views
-- Create
-- View vCategoryByProductByInventoryByCountByEmployeeChaiChang
-- As
-- Select Top 100 CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = EmployeeFirstName +' '+ EmployeeLastName
-- From Categories as C inner join Products as P
-- On C.CategoryID = P.CategoryID
-- Inner Join Inventories as I
-- On  I.ProductID = P.ProductID
-- Inner Join Employees as E
-- On E.EmployeeID = I.EmployeeID
-- Where P.ProductName IN 
--	(Select ProductName From Products Where ProductName IN ('Chai','Chang'))
-- Order By InventoryDate, CategoryName, ProductName;
--Go

-- Select * From vCategoryByProductByInventoryByCountByEmployeeChaiChang

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!


Create
View vEmployeeByManager
As
Select Top 100 Mgr.EmployeeFirstName +' '+ Mgr.EmployeeLastName as Manager, Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName as Employee
 From Employees as Mgr Inner Join Employees as Emp
   On Mgr.EmployeeID = Emp.ManagerID
   Order By Manager, Employee;
   go

Select * From vEmployeeByManager


-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- 5th Draft Other Work Below - Realized I needed to join on Views not tabels.  All previous drafts based on tables, and all showed logical misunderstanding of Employee Manager relationship

Create
View vOmnibus
As
Select Top 100000 vC.CategoryID, CategoryName, vP.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, vEmp.EmployeeID, [Employee] = vEmp.EmployeeFirstName +' '+ vEmp.EmployeeLastName, [Manager] = vMgr.EmployeeFirstName +' '+ vMgr.EmployeeLastName
From vCategories as vC Inner Join vProducts as vP
On vC.CategoryID = vP.CategoryID
Inner Join vInventories as vI 
On vI.ProductID = vP.ProductID
Inner Join vEmployees as vEmp
On vEmp.EmployeeID = vI.EmployeeID
Inner Join Employees as vMgr
On vEmp.ManagerID = vMgr.EmployeeID 
Order by CategoryID, ProductName, UnitPrice, InventoryID, InventoryDate, vMgr.ManagerID;
Go

Select * From vOmnibus



-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan


--First Draft Employees and Managers not correct

--Select C.CategoryID, CategoryName, P.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, E.EmployeeID, [Employee] = E.EmployeeFirstName +' '+ E.EmployeeLastName, [Manager] = EmployeeFirstName +' '+ EmployeeLastName
--From Categories as C Inner Join Products as P
--On C.CategoryID = P.CategoryID
--Inner Join Inventories as I 
--On I.ProductID = P.ProductID
--Inner Join Employees as E
--On E.EmployeeID = I.EmployeeID
--Need that self join
--Order by CategoryID, ProductName, UnitPrice, InventoryID, InventoryDate;
--Go

--Second Draft - The Dumpster Fire Begins

--Select C.CategoryID, CategoryName, P.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, Emp.EmployeeID, [Employee] = Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName, [Manager] = EmployeeFirstName +' '+ EmployeeLastName
--From Categories as C Inner Join Products as P
--On C.CategoryID = P.CategoryID
--Inner Join Inventories as I 
--On I.ProductID = P.ProductID
--Inner Join Employees as Emp
--On Emp.EmployeeID = I.EmployeeID
--Inner Join Emp.ManagerID as Mgr
--On ManagerID = Emp.EmployeeID
--Order by CategoryID, ProductName, UnitPrice, InventoryID, InventoryDate;
--Go

--Third Draft - The Dumpster Fire Continues

--Select C.CategoryID, CategoryName, P.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, Emp.EmployeeID, [Employee] = Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName, [Manager] = Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName
--From Categories as C Inner Join Products as P
--On C.CategoryID = P.CategoryID
--Inner Join Inventories as I 
--On I.ProductID = P.ProductID
--Inner Join Employees as Emp
--On Emp.EmployeeID = I.EmployeeID
--Where Exists 
--(Select [Manager] = Mgr.EmployeeFirstName +' '+ Mgr.EmployeeLastName, [Employee] = Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName
--From Employees as Emp Inner Join Employees Mgr
--On Mgr.ManagerID = Emp.EmployeeID)
--Order by CategoryID, ProductName, UnitPrice, InventoryID, InventoryDate;
--Go

-- 4th Draft --

-- Create
-- View vOmnibus
-- As
-- Select Top 100000 C.CategoryID, CategoryName, P.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, Emp.EmployeeID, [Employee] = Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName, [Manager] = Mgr.EmployeeFirstName +' '+ Mgr.EmployeeLastName
-- From Categories as C Inner Join Products as P
-- On C.CategoryID = P.CategoryID
-- Inner Join Inventories as I 
-- On I.ProductID = P.ProductID
-- Inner Join Employees as Emp
-- On Emp.EmployeeID = I.EmployeeID
-- Inner Join Employees as Mgr
-- On Emp.ManagerID = Mgr.EmployeeID  -- DOH!!!
-- Order by CategoryID, ProductName, UnitPrice, InventoryID, InventoryDate, Mgr.ManagerID;
-- Go




-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/