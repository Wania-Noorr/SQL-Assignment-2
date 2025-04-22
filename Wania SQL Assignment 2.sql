-- -----------------------------------------------------------------------------------------------------------------------------------------
-- DDL/DML CHANGES


-- [Question 1] use DDL commands to add a column to the customers table called street. add this column directly after the address column
alter table customers 
add column street text (100) 
AFTER address;


-- [Question 2] update this column by extracting the street name from address
-- (hint: MySQL also has text fucntions like substring_index, mid/left/right functions the same as excel. You can first test these with SELECT before using UPDATE)

UPDATE customers 
SET 
    street = SUBSTRING(address, 4);
 

-- [Question 3] Using DDL commands, add a column called stock_level to the items table.
alter table items
add column stock_level varchar (100);

-- [Question 4] Use CASE to update the stock_level column in the following way:
-- low stock if the amount is below 20
-- moderate stock if the amount is between 20 and 50
-- high stock if the amount is over 50

UPDATE items 
SET 
    stock_level = CASE
        WHEN amount_in_stock < 20 THEN 'low stock'
        WHEN amount_in_stock BETWEEN 20 AND 50 THEN 'moderate stock'
        ELSE 'high stock'
    END;

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Analysis 


-- [Question 5] In a SIMPLE SELECT query, make a column called price_label in which label each item's price as:
-- low price if its price is below 10
-- moderate price if its price is between 10 and 50
-- high price if its price is above 50
-- "unavailable" in all other cases
-- order this query by price in descending order

SELECT 
    item_price,
    CASE
        WHEN item_price < 10 THEN 'low price'
        WHEN item_price BETWEEN 10 AND 50 THEN 'moderate price'
        WHEN item_price > 50 THEN 'high price'
        ELSE 'unavailable'
    END AS price_label
FROM
    items
ORDER BY item_price DESC;


-- [Question 6]
-- Find out the total number of orders per street per city. Your results should show street, city and total_orders
-- results should be ordered by street in ascending order and cities in descending order (Hint: USE JOIN AND GROUP BY)

SELECT 
    c.street, c.city, COUNT(o.order_id) AS Total_orders
FROM
    customers c
        INNER JOIN
    orders o ON o.customer_id = c.customer_id
GROUP BY c.street , c.city
ORDER BY c.street ASC , c.city DESC;


-- [Question 7]
-- USING A JOIN, select the following:
-- customer_id, last name, address, phone number, order id, order date, item name, item type, and item price. 
SELECT 
    c.customer_id,
    c.last_name,
    c.address,
    c.phone_number,
    o.order_id,
    o.order_date,
    i.item_name,
    i.item_type,
    i.item_price
FROM
    customers c
        INNER JOIN
    orders o ON o.customer_id = c.customer_id
        INNER JOIN
    items i ON o.item_id = i.item_id;


-- [Question 8]
-- USING A JOIN, select customer_ids, first names, last names and addresses of customers who have never placed an order.
-- Only these four columns should show in your results
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.address
FROM
    orders o
        RIGHT JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_id IS NULL;

-- [Question 9]
-- DO THE EXACT SAME AS ABOVE USING A MULTI-ROW SUBQUERY IN THE WHERE CLAUSE
-- select customer_ids, first_names, last_names and addresses of customers who have never placed an order.
-- Only these four columns should show in your results
SELECT 
    customer_id, first_name, last_name, address
FROM
    customers
WHERE
    customer_id NOT IN (SELECT 
            customer_id
        FROM
            orders);
  
-- [Question 10]
-- USING A CORRELATED SUBQUERY IN THE WHERE CLAUSE:
-- select item id, item name, item type and item price for all those items that have a price higher than the average price FOR THEIR ITEM TYPE (NOT average of the whole column)
-- order your result by item type; (hint: Use correlated subquery to match items table with itself by matching item_type) 
SELECT 
    item_id, item_name, item_type, item_price
FROM
    items AS i_outer
WHERE
    item_price > (SELECT 
            AVG(i_inner.item_price)
        FROM
            items AS i_inner
        WHERE
            i_inner.item_type = i_outer.item_type)
ORDER BY item_type;

-- [Question 11]
-- USING A SUBQUERY IN THE WHERE CLAUSE, find out customer ids, the order date and item id of their most recent order
-- order your result by customer_id
SELECT 
    customer_id, order_date, item_id
FROM
    orders AS o
WHERE
    order_date = (SELECT 
            MAX(order_date)
        FROM
            orders
        WHERE
            o.customer_id = customer_id)
ORDER BY customer_id;

-- [Question 12] 
-- USE A JOIN to find out which customers placed an order in their birth MONTH
-- Your results should show customer_id, date_of_birth, order_date (hint: match month of order_date with month of date_of_birth)
SELECT 
    c.customer_id, c.date_of_birth, o.order_date
FROM
    customers c
        JOIN
    orders o ON o.customer_id = c.customer_id
WHERE
    MONTH(c.date_of_birth) = MONTH(o.order_date)
ORDER BY c.customer_id;

-- [Question 13]
-- USE A MULTI COLUMN SUBQUERY to find out which customers placed an order on their birth DAY (month+day like date of birth is 4th August, 2001 while order date is 4th August)
-- Your results should show customer_id and date_of_birth
SELECT 
    c.customer_id, c.date_of_birth
FROM
    customers c
WHERE
    (MONTH(date_of_birth) , DAY(date_of_birth)) IN (SELECT 
            MONTH(order_date), DAY(order_date)
        FROM
            orders o
        WHERE
            o.customer_id = c.customer_id);


