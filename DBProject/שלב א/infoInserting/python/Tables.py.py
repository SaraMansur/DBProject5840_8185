import random
from datetime import datetime, timedelta

# רשימות שמות פרטיים ושמות משפחה
first_names = ["Aharon", "Moshe", "David", "Yosef", "Miriam", "Esther", "Rachel", "Sarah", "Noa", "Omer", "Itay",
               "Daniel", "Shira", "Tamar", "Yonatan", "Eli", "Leah", "Yael", "Avigail", "Natan"]
last_names = ["Cohen", "Levi", "Mizrahi", "Peretz", "Biton", "Avraham", "Gabbay", "Shalom", "Baruch", "Shimon", "Dayan",
              "Tamir", "Segal", "Malka", "Sharabi", "Ezra", "Katz", "Shapira", "Tzadok", "Rahmani"]

# מבנה הטבלאות
products = [
    "Milk", "Bread", "Eggs", "Cheese", "Butter", "Tomato", "Potato", "Chicken", "Beef", "Fish",
    "Rice", "Pasta", "Sugar", "Salt", "Oil", "Yogurt", "Orange", "Apple", "Banana", "Grapes",
    "Carrot", "Cucumber", "Lettuce", "Strawberry", "Blueberry", "Peach", "Pear", "Mango", "Coconut",
    "Honey", "Jam", "Chocolate", "Tea", "Coffee", "Water", "Juice", "Soda", "Cereal", "Flour",
    "Pizza", "Ice Cream", "Peanut Butter", "Olives", "Pickles", "Chicken Wings", "Avocado", "Soy Sauce",
    "Ketchup", "Mustard", "Chips", "Popcorn", "Spaghetti Sauce", "Lemon", "Lime", "Ginger", "Garlic",
    "Tofu", "Salmon", "Turkey", "Lamb", "Duck", "Pineapple", "Papaya", "Cranberries", "Almonds", "Walnuts",
    "Cashews", "Peanuts", "Shrimp", "Mushrooms", "Zucchini", "Celery", "Onions", "Bell Pepper", "Radish"
]

roles = ["Manager", "Cashier", "Stocker", "Supervisor", "Accountant", "Technician", "Security", "Marketing", "Cleaner",
         "HR"]
role_statuses = ["active", "inactive", "suspended"]
order_statuses = ["ordered", "shipped", "delivered", "cancelled"]
departments = ["Dairy", "Bakery", "Grocery", "Meat", "Frozen", "Vegetables", "Beverages"]

output_file = "generated_insert.sql"

# מחוללי מספרים
phone_numbers = random.sample(range(100000000, 999999999), 800)


# יצירת שמות ייחודיים לעובדים וללקוחות
def generate_unique_names(count):
    names = set()
    while len(names) < count:
        name = f"{random.choice(first_names)} {random.choice(last_names)}"
        names.add(name)
    return list(names)


employee_names = generate_unique_names(400)
customer_names = generate_unique_names(400)

employees = [(i, employee_names[i - 1], phone_numbers[i - 1]) for i in range(1, 401)]
customers = [(i, customer_names[i - 1], phone_numbers[i + 399]) for i in range(1, 401)]

products_data = [(i, random.choice(products), random.randint(10, 500), round(random.uniform(10, 100), 2),
                  (datetime.today() + timedelta(days=random.randint(30, 365))).strftime('%Y-%m-%d'))
                 for i in range(1, 401)]
orders = [(i, (datetime.today() - timedelta(days=random.randint(1, 730))).strftime('%Y-%m-%d'),
           random.choice(order_statuses), 1) for i in range(1, 401)]

# חישוב סכומי הזמנות
order_totals = {}
order_prods = []
order_product_pairs = set()  # כדי לוודא שאין כפילויות של זוגות (ordId, pId)

for _ in range(800):  # 800 מוצרים בהזמנות כדי שיהיה פיזור טוב
    ord_id = random.randint(1, 400)
    p_id = random.randint(1, 400)

    # אם הצמד (ord_id, p_id) כבר קיים, נבחר מחדש
    while (ord_id, p_id) in order_product_pairs:
        ord_id = random.randint(1, 400)
        p_id = random.randint(1, 400)

    amount = random.randint(1, 10)
    price = next(p[3] for p in products_data if p[0] == p_id)
    cost = amount * price
    order_prods.append((amount, p_id, ord_id))
    order_product_pairs.add((ord_id, p_id))  # הוספת הצמד למערכת
    order_totals[ord_id] = order_totals.get(ord_id, 0) + cost

# שיוך סכומים להזמנות
orders = [(o[0], o[1], o[2], max(1, round(order_totals.get(o[0], 1)))) for o in orders]

# שיוך לקוחות להזמנות
customers = [(c[0], c[1], c[2], random.randint(1, 400)) for c in customers]

# שיוך תפקידים לעובדים
roles_data = [(i, random.choice(roles), random.choice(role_statuses), random.randint(1, 400))
              for i in range(1, 401)]

# שיוך מחלקות
departments_data = [
    (i, random.choice(departments), random.randint(1, 20), random.randint(1, 400), random.randint(1, 400))
    for i in range(1, 401)]

# כתיבת קובץ SQL
with open(output_file, "w", encoding="utf-8") as f:
    f.write("-- Insert into product\n")
    for p in products_data:
        f.write(
            f"INSERT INTO product (pId, pName, stock, price, validity) VALUES ({p[0]}, '{p[1]}', {p[2]}, {p[3]}, '{p[4]}');\n")

    f.write("\n-- Insert into employee\n")
    for e in employees:
        f.write(f"INSERT INTO employee (eId, eName, ePhone) VALUES ({e[0]}, '{e[1]}', {e[2]});\n")

    f.write("\n-- Insert into role\n")
    for r in roles_data:
        f.write(f"INSERT INTO role (rId, alias, rStatus, eId) VALUES ({r[0]}, '{r[1]}', '{r[2]}', {r[3]});\n")

    f.write("\n-- Insert into orders\n")
    for o in orders:
        f.write(
            f"INSERT INTO orders (ordId, ordDate, ordStatus, ordCost) VALUES ({o[0]}, '{o[1]}', '{o[2]}', {o[3]});\n")

    f.write("\n-- Insert into customer\n")
    for c in customers:
        f.write(f"INSERT INTO customer (cId, cName, cPhone, ordId) VALUES ({c[0]}, '{c[1]}', {c[2]}, {c[3]});\n")

    f.write("\n-- Insert into orderProd\n")
    for op in order_prods:
        f.write(f"INSERT INTO orderProd (amount, pId, ordId) VALUES ({op[0]}, {op[1]}, {op[2]});\n")

    f.write("\n-- Insert into department\n")
    for d in departments_data:
        f.write(
            f"INSERT INTO department (depId, depName, aisleNum, pId, eId) VALUES ({d[0]}, '{d[1]}', {d[2]}, {d[3]}, {d[4]});\n")

print(f"SQL insert statements saved to {output_file}")
