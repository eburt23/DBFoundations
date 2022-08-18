--*************************************************************************--
-- Title: Assignment06
-- Author: Edna Burton
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Edna Burton,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_EBurton')
	 Begin 
	  Alter Database [Assignment06DB_EBurton] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_EBurton;
	 End
	Create Database Assignment06DB_EBurton;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_EBurton;

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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
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
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
go

--Select CategoryID,CategoryName from dbo.Categories
--Select ProductID,ProductName from dbo.products 
--Select EmployeeID,EmployeeFirstName,EmployeeLastname,ManagerID from dbo.Employees
--select InventoryId,InventoryDate,ProdcutID,count from dbo.inventories

--Create View vCategories -- done --need to drop veiw and redo
--with Schemabinding 
--as Select CategoryID,CategoryName
--from dbo.Categories
--go 
 Select * from  dbo.vCategories
 
--Create View vProducts  
--with Schemabinding 
--as Select ProductID,ProductName
--from dbo.products
--go 

 Select * from  dbo.vProducts

--Create View vEmployees
--with Schemabinding 
--as Select EmployeeID,EmployeeFirstName,EmployeeLastname,ManagerID
--from dbo.Employees
--go 

 Select * from dbo.vEmployees

--Create View vInventories
--with Schemabinding 
--as Select InventoryID,InventoryDate,ProductID,Count
--from dbo.Inventories
--go 

 Select * from dbo.vInventories

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on vCategories to public;
Grant Select on vCategories to public;

Deny Select on vproducts to public;
Grant Select on vproducts to public;

Deny Select on vEmployees to public;
Grant Select on vEmployees to public;

Deny Select on vInventories to public;
Grant Select on vInventories to public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

--Select * From Categories; -- all the data/informaiton 
--Select * From Products;

--Select CategoryName From Categories; -- only tables/columns to solve question  
--Select ProductName,UnitPrice From Products;

--Select CategoryName, Productname,UnitPrice  -- combine data for results
--From Categories 
--Join Products On Categories.CategoryID = Products.CategoryId;

--Select CategoryName, Productname,UnitPrice  -- order by Category then Products
--From Categories 
--Join Products On Categories.CategoryID = Products.CategoryId
--Order By CategoryName,Productname;

--Create --drop

--Create View vProductsByCategories
--As  
--Select Top 100000 -- percent
--CategoryName, Productname,UnitPrice  -- adding aliasing
--From dbo.Categories as e
--Join Products as b On e.CategoryID = b.CategoryId
--Order By CategoryName,Productname

Select * from dbo.vProductsByCategories


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

--Create View vInventoriesByProductsByDates
--As  
--Select Top 100000 ProductName,InventoryDate,count
--from products
--join Inventories
--on Products.ProductID = Inventories.ProductID
--order by ProductName,InventoryDate,Count
--go

Select * from vInventoriesByProductsByDates


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

create view vInventoriesByEmployeesByDates
As
Select 
top 10000
InventoryDate,[employeeName] = e.EmployeeFirstName + ' '+ e.employeelastName--,numberoforders = count

 From employees as e
 join Inventories as I
 On e.employeeID = i.InventoryID
 order by InventoryDate,employeeName,count

 
 select * from vInventoriesByEmployeesByDates

 -- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


/*Select * from products --- all data
Select * from Categories
select * from Inventories

select categoryname from Categories
Select ProductName from products
select inventorydate,count from Inventories

join categoryID to Products
join Employees to inventory 

 drop
 create view  vInventoriesForChaiAndChang
AS 
Select Top 100000
 CategoryName,ProductName,InventoryDate, Count
From Categories as c 
join Products
on c.CategoryID = ProductID  
join Inventories as i
on i.InventoryID = InventoryID
join Employees as e
on e.EmployeeID = InventoryID
order by inventorydate,CategoryName,ProductName
*/

select * from vInventoriesForChaiAndChang


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

/*
Select * from products --- all data
Select * from Categories
select * from Inventories

select categoryname from Categories
Select ProductName from products
select inventorydate,count from Inventories

join categoryID to Products
join Employees to inventory 


create view vInventoriesByProductsByEmployees
as 
Select Top 100000 CategoryName,ProductName,InventoryDate, Count,
 [EmployeeName] = e.EmployeeFirstName + ' '+ e.employeelastName
From Categories as c 
join Products
on c.CategoryID = ProductID  
join Inventories as i
on i.InventoryID = InventoryID
join Employees as e
on e.EmployeeID = InventoryID
order by inventorydate,CategoryName,ProductName
*/
select * from vInventoriesByProductsByEmployees


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth
/*
Create view vcategoriebyinventorycount
as
Select top 10000 CategoryName,ProductName,inventorydate, count 
from Products

inner join Categories
on categories.CategoryID = products. ProductID
inner join Inventories
on inventories.InventoryID = products.productID
order by categoryName,ProductName,inventorydate,count
*/
Select * from vcategoriebyinventorycount


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

/*
Select * from employees -- all data
Select EmployeeFirstName, EmployeeLastname,ManagerID -- tables
from Employees;
*/ 

Create view vEmployeesByManager
as
 --Select 
-- [Manager] = e.EmployeeFirstName + ' '+ e.employeelastName
--,[Employee] = e.EmployeeFirstName + ' '+ e.EmployeeLastName

 --From Employees   
 --where employeedID <> managerID 
 --employeeID = managerID 
 --order by m.managerID;

/* Create view vEmployeesByManager
as

 Select 
 top 10000
 [Manager] = e.EmployeeFirstName + ' '+ e.employeelastName
 ,[Employee] = e.EmployeeFirstName + ' '+ e.EmployeeLastName
 From Employees as e 
 order by ManagerID
*/  
 
Select * from vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChang]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/