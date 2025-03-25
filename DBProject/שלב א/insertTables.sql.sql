-- Insert into product
INSERT INTO product (pId, pName, stock, price, validity) VALUES (1, 'Milk', 50, 5.99, '2025-06-01');
INSERT INTO product (pId, pName, stock, price, validity) VALUES (2, 'Bread', 30, 3.49, '2025-06-05');
INSERT INTO product (pId, pName, stock, price, validity) VALUES (3, 'Eggs', 20, 7.99, '2025-06-10');

-- Insert into employee
INSERT INTO employee (eId, eName, ePhone) VALUES (1, 'Alice Johnson', '123456789');
INSERT INTO employee (eId, eName, ePhone) VALUES (2, 'Bob Smith', '987654321');
INSERT INTO employee (eId, eName, ePhone) VALUES (3, 'Charlie Brown', '555555555');

-- Insert into role
INSERT INTO role (rId, alias, rStatus, eId) VALUES (1, 'Manager', 'active', 1);
INSERT INTO role (rId, alias, rStatus, eId) VALUES (2, 'Cashier', 'inactive', 2);
INSERT INTO role (rId, alias, rStatus, eId) VALUES (3, 'Stocker', 'active', 3);

-- Insert into orders
INSERT INTO orders (ordId, ordDate, ordStatus, ordCost) VALUES (1, '2025-03-20', 'ordered', 15.99);
INSERT INTO orders (ordId, ordDate, ordStatus, ordCost) VALUES (2, '2025-03-18', 'shipped', 27.50);
INSERT INTO orders (ordId, ordDate, ordStatus, ordCost) VALUES (3, '2025-03-15', 'delivered', 10.75);

-- Insert into customer
INSERT INTO customer (cId, cName, cPhone, ordId) VALUES (1, 'David Miller', '111222333', 1);
INSERT INTO customer (cId, cName, cPhone, ordId) VALUES (2, 'Sarah White', '444555666', 2);
INSERT INTO customer (cId, cName, cPhone, ordId) VALUES (3, 'James Brown', '777888999', 3);

-- Insert into orderProd
INSERT INTO orderProd (amount, pId, ordId) VALUES (2, 1, 1);
INSERT INTO orderProd (amount, pId, ordId) VALUES (1, 2, 2);
INSERT INTO orderProd (amount, pId, ordId) VALUES (3, 3, 3);

-- Insert into department
INSERT INTO department (depId, depName, aisleNum, pId, eId) VALUES (1, 'Dairy', 5, 1, 1);
INSERT INTO department (depId, depName, aisleNum, pId, eId) VALUES (2, 'Bakery', 3, 2, 2);
INSERT INTO department (depId, depName, aisleNum, pId, eId) VALUES (3, 'Grocery', 7, 3, 3);
