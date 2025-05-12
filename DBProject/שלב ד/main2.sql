-- Main Program 2: Call assign_employee_to_purchases() and check_product_availability()
DO $$
DECLARE
    rec RECORD;
BEGIN
    -- Call the procedure
    CALL assign_employee_to_purchases();

    -- Call the function and loop over results
    FOR rec IN SELECT * FROM check_product_availability(3)
    LOOP
        RAISE NOTICE 'Supplier: %, SID: %, Quantity: %', rec.sname, rec.sid, rec.total_amount;
    END LOOP;
END;
$$;