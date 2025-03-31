-- הוספת מחלקות
INSERT INTO department (depId, depName, aisleNum) VALUES
(1, 'Produce', 5),
(2, 'Dairy', 8),
(3, 'Bakery', 2);

-- הוספת תפקידים
INSERT INTO role (rId, alias, rStatus) VALUES
(1, 'Cashier', 'active'),
(2, 'Manager', 'active'),
(3, 'Stocker', 'inactive');

-- הוספת לקוחות
INSERT INTO customer (cId, cName, cPhone) VALUES
(1, 'Alice', 123456789999),
(2, 'Bob', 987654321111),
(3, 'Charlie', 555666777777);

-- הוספת מוצרים
INSERT INTO product (pId, pName, stock, Price, validity, depId) VALUES
(11111, 'Apple', 100, 2.5, '2025-12-31', 1),
(22222, 'Milk', 50, 5.0, '2026-06-15', 2),
(33333, 'Bread', 30, 3.0, '2026-04-10', 3);

-- הוספת עובדים
INSERT INTO employee (eId, eName, ePhone, depId, rId) VALUES
(1, 'David', 111222333333, 1, 1),
(2, 'Emma', 444555666666, 2, 2),
(3, 'Frank', 777888999999, 3, 3);

-- הוספת הזמנות
INSERT INTO orders (ordId, ordDate, ordStatus, ordCost, cId) VALUES
(1, '2024-03-01', 'ordered', 50, 1),
(2, '2024-03-02', 'shipped', 30, 2),
(3, '2024-03-03', 'delivered', 75, 3);

-- הוספת פריטים להזמנות
INSERT INTO orderProd (amount, pId, ordId) VALUES
(2, 11111, 1), -- שני תפוחים בהזמנה 1
(1, 22222, 2), -- חלב בהזמנה 2
(3, 33333, 3); -- שלושה לחמים בהזמנה 3
