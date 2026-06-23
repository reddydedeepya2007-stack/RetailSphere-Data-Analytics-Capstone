USE retailsphere_db;

CREATE TABLE categories (
 category_id INT PRIMARY KEY,
 category_name VARCHAR(50) UNIQUE
);

CREATE TABLE products (
 product_id INT PRIMARY KEY,
 product_name VARCHAR(100) NOT NULL,
 category_id INT,
 price DECIMAL(10,2) CHECK(price > 0),
 stock_quantity INT DEFAULT 0,
 FOREIGN KEY(category_id)
 REFERENCES categories(category_id)
);

CREATE TABLE orders (
 order_id INT PRIMARY KEY,
 customer_id INT,
 order_date DATE NOT NULL,
 order_status VARCHAR(30)
 DEFAULT 'Processing',
 FOREIGN KEY(customer_id)
 REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
 order_item_id INT PRIMARY KEY,
 order_id INT,
 product_id INT,
 quantity INT CHECK(quantity > 0),
 unit_price DECIMAL(10,2) NOT NULL,
 FOREIGN KEY(order_id)
 REFERENCES orders(order_id),
 FOREIGN KEY(product_id)
 REFERENCES products(product_id)
);

CREATE TABLE suppliers (
 supplier_id INT PRIMARY KEY,
 supplier_name VARCHAR(100) NOT NULL,
 city VARCHAR(50) NOT NULL
);

CREATE TABLE product_suppliers (
 supplier_id INT,
 product_id INT,
 FOREIGN KEY(supplier_id)
 REFERENCES suppliers(supplier_id),
 FOREIGN KEY(product_id)
 REFERENCES products(product_id)
);
USE retailsphere_db;


INSERT INTO categories VALUES
(1,'Electronics'),
(2,'Fashion'),
(3,'Home Appliances');


INSERT INTO customers VALUES
(101,'Arun','Kumar','arun@gmail.com','Chennai','2025-01-10'),
(102,'Meena','Raj','meena@gmail.com','Bangalore','2025-02-15'),
(103,'John','David','john@gmail.com','Hyderabad','2025-03-20'),
(104,'Sita','Rao','sita@gmail.com','Mumbai','2025-04-01');


INSERT INTO products VALUES
(201,'Laptop',1,75000,20),
(202,'Mobile',1,30000,50),
(203,'T-Shirt',2,1500,100),
(204,'Washing Machine',3,25000,10),
(205,'Headphones',1,2000,40);


INSERT INTO orders VALUES
(301,101,'2025-05-01','Delivered'),
(302,102,'2025-05-03','Processing'),
(303,103,'2025-05-05','Delivered'),
(304,101,'2025-05-07','Cancelled');


INSERT INTO order_items VALUES
(1,301,201,1,75000),
(2,301,205,2,2000),
(3,302,203,3,1500),
(4,303,202,1,30000),
(5,304,204,1,25000);


INSERT INTO suppliers VALUES
(401,'Tech Distributors','Chennai'),
(402,'Fashion Hub','Delhi'),
(403,'Appliance World','Mumbai');


INSERT INTO product_suppliers VALUES
(401,201),
(401,202),
(402,203),
(403,204),
(401,205);
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
USE retailsphere_db;


SELECT * FROM customers;


SELECT product_name, price
FROM products;


SELECT *
FROM customers
WHERE city='Chennai';


SELECT *
FROM products
WHERE price>20000;


SELECT *
FROM products
ORDER BY price DESC;


SELECT *
FROM products
ORDER BY price DESC
LIMIT 3;


SELECT DISTINCT city
FROM customers;


UPDATE products
SET stock_quantity=60
WHERE product_id=202;


DELETE FROM orders
WHERE order_status='Cancelled';


SELECT *
FROM products
WHERE price BETWEEN 2000 AND 50000;
USE retailsphere_db;


SELECT COUNT(*) AS total_customers
FROM customers;


SELECT AVG(price) AS average_price
FROM products;


SELECT MAX(price) AS max_price
FROM products;


SELECT MIN(price) AS min_price
FROM products;


SELECT SUM(quantity * unit_price)
AS total_revenue
FROM order_items;


SELECT c.category_name,
AVG(p.price) AS avg_price
FROM products p
INNER JOIN categories c
ON p.category_id=c.category_id
GROUP BY c.category_name;


SELECT c.category_name,
COUNT(p.product_id)
AS total_products
FROM categories c
LEFT JOIN products p
ON c.category_id=p.category_id
GROUP BY c.category_name;


SELECT c.category_name,
AVG(p.price)
AS avg_price
FROM products p
INNER JOIN categories c
ON p.category_id=c.category_id
GROUP BY c.category_name
HAVING AVG(p.price)>10000;
USE retailsphere_db;


SELECT c.first_name,
o.order_id,
o.order_date
FROM customers c
INNER JOIN orders o
ON c.customer_id=o.customer_id;


SELECT p.product_name,
c.category_name
FROM products p
INNER JOIN categories c
ON p.category_id=c.category_id;


SELECT c.first_name,
o.order_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id;


SELECT o.order_id,
c.first_name
FROM customers c
RIGHT JOIN orders o
ON c.customer_id=o.customer_id;


SELECT c.first_name,
p.product_name
FROM customers c
CROSS JOIN products p;


CREATE TABLE employees(
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 manager_id INT
);

INSERT INTO employees VALUES
(1,'Arun',NULL),
(2,'Meena',1),
(3,'Raj',1);

SELECT e.emp_name AS employee,
m.emp_name AS manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id=m.emp_id;


SELECT s.supplier_name,
p.product_name
FROM suppliers s
INNER JOIN product_suppliers ps
ON s.supplier_id=ps.supplier_id
INNER JOIN products p
ON ps.product_id=p.product_id;
USE retailsphere_db;


SELECT *
FROM products
WHERE price>(
 SELECT AVG(price)
 FROM products
);


SELECT *
FROM customers c
WHERE EXISTS(
 SELECT 1
 FROM orders o
 WHERE o.customer_id=c.customer_id
);


SELECT *
FROM products
WHERE price>ALL(
 SELECT price
 FROM products p
 INNER JOIN categories c
 ON p.category_id=c.category_id
 WHERE c.category_name='Fashion'
);


SELECT *
FROM products
WHERE price>ANY(
 SELECT price
 FROM products p
 INNER JOIN categories c
 ON p.category_id=c.category_id
 WHERE c.category_name='Electronics'
);


SELECT product_name,
price,
CASE
 WHEN price>=50000 THEN 'Premium'
 WHEN price>=10000 THEN 'Mid Range'
 ELSE 'Budget'
END AS product_category
FROM products;


CREATE VIEW finance_report AS
SELECT o.order_id,
c.first_name,
p.product_name,
oi.quantity,
oi.unit_price,
(oi.quantity*oi.unit_price)
AS total_amount
FROM orders o
INNER JOIN customers c
ON o.customer_id=c.customer_id
INNER JOIN order_items oi
ON o.order_id=oi.order_id
INNER JOIN products p
ON oi.product_id=p.product_id;


DELIMITER //

CREATE PROCEDURE add_new_order(
 IN p_order_id INT,
 IN p_customer_id INT,
 IN p_order_date DATE,
 IN p_status VARCHAR(30)
)
BEGIN
 INSERT INTO orders
 VALUES(
  p_order_id,
  p_customer_id,
  p_order_date,
  p_status
 );
END //

DELIMITER ;


CREATE INDEX idx_product_name
ON products(product_name);

CREATE INDEX idx_customer_city
ON customers(city);



SELECT p.product_name,
SUM(oi.quantity)
AS total_sold
FROM products p
INNER JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;


CREATE VIEW customer_order_summary AS
SELECT c.customer_id,
c.first_name,
COUNT(o.order_id)
AS total_orders
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY
c.customer_id,
c.first_name;
