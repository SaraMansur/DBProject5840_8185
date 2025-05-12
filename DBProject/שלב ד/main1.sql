-- Main Program 1: Call mark_cancelled_purchases() and get_customer_purchases()
DO $$
DECLARE
    c refcursor;
    r RECORD;
BEGIN
    -- Call the procedure
    CALL mark_cancelled_purchases();

    -- Call the function and loop over results
    c := get_customer_purchases(1);
    LOOP
        FETCH c INTO r;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Purchase ID: %, Date: %, Cost: %', r.purid, r.purdate, r.purcost;
    END LOOP;
    CLOSE c;
END;
$$;