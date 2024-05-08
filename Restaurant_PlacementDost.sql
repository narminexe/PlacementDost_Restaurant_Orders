-- converting dataset to SQL Database --
-- select all columns from menu_items --
-- select the first 5 rows from order_details --
select * from menu_items;
select * from order_details order by 1 offset 0 rows fetch first 5 rows only;

-- select the item_name and price columns for items in the 'Main Course' category --
-- sort the result by price in descending order --
select item_name, price from menu_items where category = 'Asian';
select item_name, price from menu_items where category = 'Asian' order by price desc;

-- calculate the average price of menu items -- 
-- find the total number of orders placed -- 
select round(avg(price),2) from menu_items;
select count(order_id) from order_details;

-- retrieve the item_name, order_date, and order_time for all items in the order_details table, including their respective menu item details --
select m.item_name, o.order_date, o.order_time, m.category, m.price
from order_details o join menu_items m on m.menu_item_id=o.item_id;

-- list the menu items (item_name) with a price greater than the average price of all menu items --
select item_name from menu_items where price> (select avg(price)from menu_items);

-- extract the month from the order_date and count the number of orders placed in each month --
select month(order_date),count(order_details_id) from order_details group by month(order_date) order by month(order_date);

-- show the categories with the average price greater than $15 --
-- include the count of items in each category --
select category, avg(price) from menu_items group by category having avg(price)>15;
select category, count(*) as number_of_items from menu_items group by category;

-- display the item_name and price, and indicate if the item is priced above $20 with a new column named 'Expensive' --
select item_name,price,
 case 
 when price>20 then 'Yes'
 else 'No'
 end as 'Expensive'
 from menu_items;

 -- update the price of the menu item with item_id = 101 to $25 --
update menu_items set price=25 where menu_item_id=101;

-- insert a new record into the menu_items table for a dessert item --
insert into menu_items(menu_item_id,item_name,category,price) values(133,'Red Velvet','American', 8);

-- delete all records from the order_details table where the order_id is less than 100 --
delete from order_details where order_id<100;

-- Rank menu items based on their prices, displaying the item_name and its rank --
select item_name, rank() over(partition by price order by menu_item_id) as price_rank from menu_items m;

-- display the item_name and the price difference from the previous and next menu item --
select item_name,price,
 price-isnull(lag(price) over(order by menu_item_id),0) as price_difference_previous,
 price-isnull(lead(price) over(order by menu_item_id),0) as price_difference_next
 from menu_items;

-- create a CTE that lists menu items with prices above $15 --
-- use the CTE to retrieve the count of such items --with A as (select *  from menu_items where  price>15) select  count(*) from A;-- retrieve the order_id, item_name, and price for all orders with their respective menu item details ---- include rows even if there is no matching menu item --select o.order_id,m.item_name,m.price,m.categoryfrom order_details o left join menu_items m on m.menu_item_id=o.item_id;-- unpivot the menu_items table to show a list of menu item properties (item_id, item_name, category, price) --select menu_item_id, attribute, value from (select menu_item_id,item_name,category, cast(price as varchar(50)) as price from menu_items) munpivot(value for attribute in (item_name,category,price)) p;
-- write a dynamic SQL query that allows users to filter menu items based on category and price range --create procedure dynamic_sql  @category nvarchar(max),  @max_price float,  @min_price floatas begin   declare @sql_query nvarchar(max)  set @sql_query = 'select * from menu_items where category = @category'  set @sql_query = @sql_query + ' and price between @min_price and @max_price'exec sp_executesql @sql_query,N'@category NVARCHAR(MAX), @min_price FLOAT, @max_price FLOAT', 
                       @category, @min_price, @max_price;
end;

exec dynamic_sql @category = 'Asian', @min_price = 5, @max_price = 25;


-- create a stored procedure that takes a menu category as input and returns the average price for that category --create procedure avg_price_per_category   @category nvarchar(50), @price float output asbeginselect @price = avg(price) from menu_items where category = @category; end;
declare @avg_price float;
 exec avg_price_per_category @category = 'Italian', @price = @avg_price output;
 select @avg_price as avg_price_italian;


 -- design a trigger that updates a log table whenever a new order is inserted into the order_details table --