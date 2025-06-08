
-- ===========================================
-- Full PL/pgSQL Script: Functions, Procedures, Triggers, and Main Programs
-- ===========================================

-- ========= FUNCTIONS =========

-- Function 1: Check product availability per supplier
CREATE OR REPLACE FUNCTION check_product_availability(p_pid INT)
RETURNS TABLE(sname character varying, sid integer, total_amount bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT s.sname, s.sid, SUM(pp.amount)
    FROM supplier s
    JOIN "order" o ON s.sid = o.sid
    JOIN ordprod op ON o.ordid = op.ordid
    JOIN product p ON op.pid = p.pid
    JOIN purprod pp ON pp.pid = p.pid
    WHERE p.pid = p_pid
    GROUP BY s.sname, s.sid;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Return all purchases of a given customer
CREATE OR REPLACE FUNCTION get_customer_purchases(p_cid INT)
RETURNS refcursor AS $$
DECLARE
    cur refcursor;
BEGIN
    OPEN cur FOR
        SELECT purid, purdate, purcost
        FROM purchase
        WHERE cid = p_cid;
    RETURN cur;
END;
$$ LANGUAGE plpgsql;

--ANOTHER FUNCTION:
-- פונקציה שמקבלת מזהה מוצר ומדפיסה את שמו והכמות במלאי
CREATE OR REPLACE FUNCTION print_product_info(p_pid INT)
RETURNS VOID AS $$
DECLARE
    v_name VARCHAR;
    v_quantity INT;
BEGIN
    -- שליפת שם המוצר והכמות למשתנים מקומיים (קורסור מרומז)
    SELECT pname, quantity
    INTO v_name, v_quantity
    FROM product
    WHERE pid = p_pid;

    -- הדפסת המידע על המוצר
    RAISE NOTICE 'Product: %, Quantity: %', v_name, v_quantity;
END;
$$ LANGUAGE plpgsql;


-- ========= PROCEDURES =========

-- Procedure 1: Mark old 'ordered' purchases as 'cancelled'
CREATE OR REPLACE PROCEDURE mark_cancelled_purchases()
AS $$
BEGIN
    UPDATE purchase
    SET purstatus = 'cancelled'
    WHERE purstatus = 'ordered'
      AND purdate < CURRENT_DATE - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- Procedure 2: Assign eid = 1 to all purchases without employee
-- Enhanced Procedure 2: Assign employee to purchases with NULL eid, with EXCEPTION handling
CREATE OR REPLACE PROCEDURE assign_employee_to_purchases()
AS $$
BEGIN
    UPDATE purchase
    SET eid = 1
    WHERE eid IS NULL;

    RAISE NOTICE 'All purchases without employee were assigned to eid=1';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'An error occurred while assigning employee: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ========= TRIGGERS =========

-- Trigger 1: Check product stock before inserting to purprod
CREATE OR REPLACE FUNCTION trg_check_stock()
RETURNS trigger AS $$
DECLARE
    available INT;
BEGIN
    SELECT quantity INTO available
    FROM product
    WHERE pid = NEW.pid;

    IF available < NEW.amount THEN
        RAISE EXCEPTION 'Not enough stock for product %', NEW.pid;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_purchase
BEFORE INSERT ON purprod
FOR EACH ROW
EXECUTE FUNCTION trg_check_stock();

-- Trigger 2: Reduce product quantity after purchase
CREATE OR REPLACE FUNCTION trg_decrease_stock()
RETURNS trigger AS $$
BEGIN
    UPDATE product
    SET quantity = quantity - NEW.amount
    WHERE pid = NEW.pid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_purchase
AFTER INSERT ON purprod
FOR EACH ROW
EXECUTE FUNCTION trg_decrease_stock();
