import random
from datetime import datetime, timedelta

# נתונים לדוגמה למחלקות
departments_data = [
    (1, 'Electronics', 10),
    (2, 'Clothing', 12),
    (3, 'Food', 15),
    (4, 'Furniture', 5),
    (5, 'Toys', 20),
    (6, 'Books', 8),
    (7, 'Sport', 7),
    (8, 'Beauty', 9),
    (9, 'Gardening', 4),
    (10, 'Music', 12),
    (11, 'Jewelry', 6),
    (12, 'Automotive', 13),
    (13, 'Health', 10),
    (14, 'Pet Supplies', 6),
    (15, 'Stationery', 5),
    (16, 'Meat', 6),
    (17, 'Vegetables', 7),
    (18, 'Bakery', 8),
    (19, 'Fish', 9),
    (20, 'Frozen Food', 10)
]

# נתונים לדוגמה לתפקידים
role_data = [
    (1, 'Manager'),
    (2, 'Salesperson'),
    (3, 'Stocker'),
    (4, 'Cashier'),
    (5, 'Supervisor'),
    (6, 'Cleaner'),
    (7, 'Security'),
    (8, 'Customer Service'),
    (9, 'Marketing'),
    (10, 'IT Support')
]

# 150 שמות שונים של מוצרים (הוספתי מוצרים נוספים של אוכל)
product_names = [
    'Laptop', 'Shirt', 'Apple', 'Sofa', 'Toy Car', 'Book', 'TV', 'Jeans', 'Banana', 'Couch',
    'Smartphone', 'Tablet', 'Headphones', 'Camera', 'Monitor', 'Speaker', 'Microwave', 'Fridge', 'Washing Machine', 'Oven',
    'Shoes', 'Jacket', 'Dress', 'T-shirt', 'Skirt', 'Sweater', 'Pants', 'Shorts', 'Boots', 'Gloves',
    'Toothpaste', 'Shampoo', 'Conditioner', 'Deodorant', 'Face Cream', 'Sunscreen', 'Perfume', 'Nail Polish', 'Lipstick', 'Mascara',
    'Desk', 'Chair', 'Bed', 'Couch', 'Coffee Table', 'Bookshelf', 'Lampshade', 'Dining Table', 'Wardrobe', 'Curtains',
    'Soccer Ball', 'Tennis Racket', 'Basketball', 'Baseball Glove', 'Hockey Stick', 'Yoga Mat', 'Bicycle', 'Jump Rope', 'Football', 'Dumbbells',
    'Dog Food', 'Cat Litter', 'Bird Cage', 'Fish Tank', 'Leash', 'Collar', 'Pet Shampoo', 'Pet Toy', 'Pet Bed', 'Pet Carrier',
    'Cucumber', 'Tomato', 'Carrot', 'Lettuce', 'Potato', 'Onion', 'Garlic', 'Broccoli', 'Spinach', 'Peas',
    # הוספת מוצרים נוספים בתחום האוכל
    'Chicken Breast', 'Beef Steak', 'Pork Chops', 'Salmon', 'Shrimp', 'Lamb Chops', 'Sausages', 'Bacon', 'Ground Beef', 'Turkey',
    'Bread', 'Croissant', 'Baguette', 'Bagel', 'Ciabatta', 'Focaccia', 'Muffins', 'Donuts', 'Cinnamon Rolls', 'Pita Bread',
    'Cheddar Cheese', 'Mozzarella Cheese', 'Parmesan Cheese', 'Cream Cheese', 'Brie Cheese', 'Gouda Cheese', 'Feta Cheese', 'Ricotta Cheese', 'Goat Cheese', 'Camembert',
    'Yogurt', 'Butter', 'Milk', 'Almond Milk', 'Soy Milk', 'Orange Juice', 'Apple Juice', 'Coconut Milk', 'Coconut Water', 'Tomato Sauce',
    'Mustard', 'Ketchup', 'Mayonnaise', 'Hot Sauce', 'Olive Oil', 'Vegetable Oil', 'Vinegar', 'Honey', 'Maple Syrup', 'Peanut Butter'
]

# יצירת מוצרים
product_data = [(i + 1, product_names[i], random.randint(0, 50), round(random.uniform(5, 200), 2),
                 (datetime.today() + timedelta(days=random.randint(1, 365))).strftime('%Y-%m-%d'),
                 random.choice(range(1, 21)))  # מקשר למחלקות שונות
                for i in range(len(product_names))]  # מותאם למספר המוצרים במערך

# יצירת לקוחות (400 לקוחות)
customer_names = [f"Customer{i}" for i in range(1, 401)]  # 400 לקוחות
customers = [(i, customer_names[i - 1], f"{random.randint(100000000000, 999999999999)}") for i in range(1, 401)]

# יצירת הזמנות (400 הזמנות)
orders = []
order_count_per_customer = {}

# כל לקוח יקבל בין 0 ל-3 הזמנות, כולל 100 לקוחות ללא הזמנה
for i in range(1, 401):  # 400 לקוחות
    if i <= 300:  # 300 לקוחות יקבלו הזמנות
        num_orders = random.randint(1, 3)  # כל לקוח יקבל בין 1 ל-3 הזמנות

        for _ in range(num_orders):
            order_date = (datetime.today() - timedelta(days=random.randint(1, 730))).strftime('%Y-%m-%d')
            order_status = random.choice(['ordered', 'shipped', 'delivered', 'cancelled'])
            order_cost = random.randint(50, 500)  # עלות הזמנה אקראית
            orders.append((len(orders) + 1, order_date, order_status, order_cost, i))  # יצירת ההזמנה
    else:
        # 100 לקוחות ללא הזמנה
        continue

# יצירת רשומות פרטי הזמנה (900 פרטי הזמנה)
order_prods = []
order_product_pairs = set()

for _ in range(900):  # 900 פרטי הזמנה
    ord_id = random.randint(1, len(orders))  # עדכון כך שיהיו הזמנות לכל הלקוחות
    p_id = random.randint(1, len(product_data))

    # אם הצמד (ord_id, p_id) כבר קיים, נבחר מחדש
    while (ord_id, p_id) in order_product_pairs:
        ord_id = random.randint(1, len(orders))
        p_id = random.randint(1, len(product_data))

    amount = random.randint(1, 10)
    price = next(p[3] for p in product_data if p[0] == p_id)
    cost = amount * price
    order_prods.append((amount, p_id, ord_id))
    order_product_pairs.add((ord_id, p_id))  # הוספת הצמד למערכת

# יצירת עובדים (100 עובדים)
employee_names = [f"Employee{i}" for i in range(1, 101)]  # 100 עובדים
employees = [(i, employee_names[i - 1], f"{random.randint(100000000000, 999999999999)}",
              random.choice(range(1, 21)), random.choice(range(1, 11))) for i in range(1, 101)]

# יצירת קובץ SQL
output_file = "output_with_employees.sql"
with open(output_file, "w", encoding="utf-8") as f:
    f.write("-- Insert into department\n")
    for d in departments_data:
        f.write(f"INSERT INTO department (depId, depName, aisleNum) VALUES ({d[0]}, '{d[1]}', {d[2]});\n")

    f.write("\n-- Insert into role\n")
    for r in role_data:
        f.write(f"INSERT INTO role (rId, alias, rStatus) VALUES ({r[0]}, '{r[1]}', 'active');\n")

    f.write("\n-- Insert into customer\n")
    for c in customers:
        f.write(f"INSERT INTO customer (cId, cName, cPhone) VALUES ({c[0]}, '{c[1]}', {c[2]});\n")

    f.write("\n-- Insert into product\n")
    for p in product_data:
        f.write(f"INSERT INTO product (pId, pName, stock, price, validity, depId) VALUES ({p[0]}, '{p[1]}', {p[2]}, {p[3]}, '{p[4]}', {p[5]});\n")

    f.write("\n-- Insert into orders\n")
    for o in orders:
        f.write(f"INSERT INTO orders (ordId, ordDate, ordStatus, ordCost, cId) VALUES ({o[0]}, '{o[1]}', '{o[2]}', {o[3]}, {o[4]});\n")

    f.write("\n-- Insert into orderProd\n")
    for op in order_prods:
        f.write(f"INSERT INTO orderProd (amount, pId, ordId) VALUES ({op[0]}, {op[1]}, {op[2]});\n")

    f.write("\n-- Insert into employee\n")
    for e in employees:
        f.write(f"INSERT INTO employee (eId, eName, ePhone, depId, rId) VALUES ({e[0]}, '{e[1]}', {e[2]}, {e[3]}, {e[4]});\n")

print(f"SQL file generated: {output_file}")
