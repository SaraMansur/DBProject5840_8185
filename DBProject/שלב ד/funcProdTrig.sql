
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

--ANOTHER FUNCTION1:
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


--ANOTHER FUNCTION2:

-- לפי מזהה לקוח מתקבל סיכום: מס רכישות, מס מוצרים, ממוצע עלות רכישה, והאם הוא לקוח חשוב
--לקוח חשוב: יותר מ5 רכישות ומהעל 1000 שח
CREATE OR REPLACE FUNCTION public.get_customer_summary(
	p_cid integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    total_orders INT;
    total_items INT;
    avg_cost NUMERIC;
    total_cost INT;
BEGIN
    -- מספר רכישות
    SELECT COUNT(*) INTO total_orders
    FROM purchase
    WHERE cid = p_cid;

    -- מספר מוצרים
    SELECT COALESCE(SUM(pp.amount), 0) INTO total_items
    FROM purchase pu
    JOIN purprod pp ON pu.purid = pp.purid
    WHERE pu.cid = p_cid;

    -- ממוצע עלות ורכישות
    SELECT COALESCE(AVG(purcost), 0), COALESCE(SUM(purcost), 0)
    INTO avg_cost, total_cost
    FROM purchase
    WHERE cid = p_cid;

    RETURN format(
        'לקוח %s ביצע %s רכישות, רכש %s מוצרים, ממוצע עלות רכישה: %s, לקוח %s',
        p_cid,
        total_orders,
        total_items,
        ROUND(avg_cost, 2),
        CASE WHEN total_orders > 5 AND total_cost > 1000 THEN 'חשוב' ELSE 'רגיל' END
    );
END;
$BODY$;

ALTER FUNCTION public.get_customer_summary(integer)
    OWNER TO cotehila;


--ANOTHER FUNCTION3:
-- FUNCTION: public.reassign_if_employee_unsuitable(integer)

-- DROP FUNCTION IF EXISTS public.reassign_if_employee_unsuitable(integer);

CREATE OR REPLACE FUNCTION public.reassign_if_employee_unsuitable(
	p_purid integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    current_role TEXT;
    current_eid INT;
    new_eid INT;
BEGIN
    -- שלב 1: שליפת העובד והתפקיד הנוכחי ברכישה
    SELECT e.eid, r.alias INTO current_eid, current_role
    FROM purchase pu
    JOIN employee e ON pu.eid = e.eid
    JOIN role r ON e.rid = r.rid
    WHERE pu.purid = p_purid;

    -- שלב 2: בדיקה אם התפקיד לא מתאים
    IF current_role NOT IN ('קופאי', 'משלוחן', 'Customer Service') THEN
        -- שלב 3: חיפוש עובד אחר שכן מתאים
        SELECT e2.eid INTO new_eid
        FROM employee e2
        JOIN role r2 ON e2.rid = r2.rid
        WHERE r2.alias IN ('קופאי', 'משלוחן', 'Customer Service')
        LIMIT 1;

        -- שלב 4: אם נמצא – עדכון הרכישה
        IF FOUND THEN
            UPDATE purchase
            SET eid = new_eid
            WHERE purid = p_purid;

            RETURN format('העובד הלא מתאים הוחלף לעובד %s', new_eid);
        ELSE
            RETURN 'לא נמצא עובד מתאים להחלפה';
        END IF;
    ELSE
        RETURN 'העובד הנוכחי כבר בתפקיד מתאים – אין צורך בהחלפה';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'לא נמצאה רכישה או שאין לה עובד משויך';
END;
$BODY$;

ALTER FUNCTION public.reassign_if_employee_unsuitable(integer)
    OWNER TO cotehila;


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