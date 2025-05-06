
-- 1. יצירת טבלת ספק
CREATE TABLE supplier (
    sid SERIAL PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    phone VARCHAR(20)
);

-- 2. יצירת טבלת הזמנה
CREATE TABLE "order" (
    ordid SERIAL PRIMARY KEY,
    orddate DATE NOT NULL,
    paymentterms VARCHAR(100),
    sid INT NOT NULL,
    FOREIGN KEY (sid) REFERENCES supplier(sid)
);

-- 3. יצירת טבלת פרטי הזמנה (ordprod)
CREATE TABLE ordprod (
    ordid INT NOT NULL,
    pid INT NOT NULL,
    amount INT NOT NULL,
    supplierprice NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (ordid, pid),
    FOREIGN KEY (ordid) REFERENCES "order"(ordid),
    FOREIGN KEY (pid) REFERENCES product(pid)
);

-- 4. הוספת שדה eid בטבלת purchase (אם לא קיים כבר)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name='purchase' AND column_name='eid'
    ) THEN
        ALTER TABLE purchase
        ADD COLUMN eid INT;
    END IF;
END$$;

-- 5. יצירת קשר בין purchase ל-employee
ALTER TABLE purchase
ADD CONSTRAINT fk_purchase_employee
FOREIGN KEY (eid) REFERENCES employee(eid);

-- 6. יצירת מפתח זר בין purprod לטבלאות purchase ו-product
ALTER TABLE purprod
ADD CONSTRAINT fk_purprod_purchase
FOREIGN KEY (purid) REFERENCES purchase(purid);

ALTER TABLE purprod
ADD CONSTRAINT fk_purprod_product
FOREIGN KEY (pid) REFERENCES product(pid);
