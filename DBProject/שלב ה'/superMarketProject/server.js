const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

const pool = new Pool({
  user: '***',
  host: 'localhost',
  database: 'mydatabase',
  password: '***',
  port: 5432,
});

pool.connect()
  .then(() => console.log('Connected to PostgreSQL!'))
  .catch(err => console.error('Connection error', err.stack));

app.get('/', (req, res) => res.sendFile(__dirname + '/public/index.html'));

app.get('/customers', (req, res) => res.sendFile(__dirname + '/public/customers.html'));
app.get('/purchases', (req, res) => res.sendFile(__dirname + '/public/purchases.html'));
app.get('/products', (req, res) => res.sendFile(__dirname + '/public/products.html'));
app.get('/departments', (req, res) => res.sendFile(__dirname + '/public/departments.html'));

app.get('/api/customer', async (req, res) => {
  try {
    const result = await pool.query('SELECT cid, cname, cphone FROM customer');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});

app.post('/api/customer', async (req, res) => {
  const { cid, cname, cphone } = req.body;
  console.log('Received customer data:', { cid, cname, cphone });
  try {
    await pool.query('INSERT INTO customer (cid, cname, cphone) VALUES ($1, $2, $3) ON CONFLICT (cid) DO NOTHING', [cid, cname, cphone || null]);
    res.status(201).send('Customer added');
  } catch (err) {
    console.error('Insert error:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});

app.delete('/api/customer/:cid', async (req, res) => {
  const { cid } = req.params;
  try {
    await pool.query('DELETE FROM customer WHERE cid = $1', [cid]);
    res.status(200).send('Customer deleted');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});

app.put('/api/customer/:cid', async (req, res) => {
  const { cid } = req.params;
  const { cname, cphone } = req.body;
  try {
    await pool.query('UPDATE customer SET cname = $1, cphone = $2 WHERE cid = $3', [cname, cphone || null, cid]);
    res.status(200).send('Customer updated');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});

app.get('/api/purchase', async (req, res) => {
  try {
    const result = await pool.query('SELECT purid, purdate, purstatus, purcost, cid, purmethod, eid FROM purchase');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});
app.post('/api/purchase', async (req, res) => {
  const { purid, purdate, purstatus, purcost, cid, purmethod, eid } = req.body;
  console.log('Received purchase data:', { purid, purdate, purstatus, purcost, cid, purmethod, eid });
  try {
    await pool.query('INSERT INTO purchase (purid, purdate, purstatus, purcost, cid, purmethod, eid) VALUES ($1, $2, $3, $4, $5, $6, $7)', [purid, purdate, purstatus, purcost, cid, purmethod, eid]);
    res.status(201).send('Purchase added');
  } catch (err) {
    console.error('Insert error:', err.stack);
    res.status(500).send('DB error: ' + err.message);
  }
});
app.delete('/api/purchase/:purid', async (req, res) => {
  const { purid } = req.params;
  try {
    await pool.query('DELETE FROM purchase WHERE purid = $1', [purid]);
    res.status(200).send('Purchase deleted');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});
app.put('/api/purchase/:purid', async (req, res) => {
  const { purid } = req.params;
  const { purdate, purstatus, purcost, cid, purmethod, eid } = req.body;
  try {
    await pool.query('UPDATE purchase SET purdate = $1, purstatus = $2, purcost = $3, cid = $4, purmethod = $5, eid = $6 WHERE purid = $7', [purdate, purstatus, purcost, cid, purmethod, eid, purid]);
    res.status(200).send('Purchase updated');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});

app.post('/api/purchase/mark-cancelled', async (req, res) => {
  try {
    await pool.query('CALL mark_cancelled_purchases()');
    res.status(200).send('Purchases marked as cancelled successfully');
  } catch (err) {
    console.error('Error in mark_cancelled_purchases:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});

app.get('/api/product', async (req, res) => {
  try {
    const result = await pool.query('SELECT pid, pname, stock, price, validity, depid, brand FROM product');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});
app.post('/api/product', async (req, res) => {
  const { pid, pname, stock, price, validity, depid, brand } = req.body;
  console.log('Received product data:', { pid, pname, stock, price, validity, depid, brand });
  try {
    await pool.query('INSERT INTO product (pid, pname, stock, price, validity, depid, brand) VALUES ($1, $2, $3, $4, $5, $6, $7)', [pid, pname, stock, price, validity, depid, brand]);
    res.status(201).send('Product added');
  } catch (err) {
    console.error('Insert error:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});
app.delete('/api/product/:pid', async (req, res) => {
  const { pid } = req.params;
  try {
    await pool.query('DELETE FROM product WHERE pid = $1', [pid]);
    res.status(200).send('Product deleted');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});
app.put('/api/product/:pid', async (req, res) => {
  const { pid } = req.params;
  const { pname, stock, price, validity, depid, brand } = req.body;
  try {
    await pool.query('UPDATE product SET pname = $1, stock = $2, price = $3, validity = $4, depid = $5, brand = $6 WHERE pid = $7', [pname, stock, price, validity, depid, brand, pid]);
    res.status(200).send('Product updated');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});

app.get('/api/department', async (req, res) => {
  try {
    const result = await pool.query('SELECT depid, depname, aislenum FROM department');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});
app.post('/api/department', async (req, res) => {
  const { depid, depname, aislenum } = req.body;
  console.log('Received department data:', { depid, depname, aislenum });
  try {
    await pool.query('INSERT INTO department (depid, depname, aislenum) VALUES ($1, $2, $3) ON CONFLICT (depid) DO NOTHING', [depid, depname, aislenum]);
    res.status(201).send('Department added');
  } catch (err) {
    console.error('Insert error:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});
app.delete('/api/department/:depid', async (req, res) => {
  const { depid } = req.params;
  try {
    await pool.query('DELETE FROM department WHERE depid = $1', [depid]);
    res.status(200).send('Department deleted');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});
app.put('/api/department/:depid', async (req, res) => {
  const { depid } = req.params;
  const { depname, aislenum } = req.body;
  try {
    await pool.query('UPDATE department SET depname = $1, aislenum = $2 WHERE depid = $3', [depname, aislenum, depid]);
    res.status(200).send('Department updated');
  } catch (err) {
    console.error(err);
    res.status(500).send('DB error');
  }
});

app.get('/api/customer/summary', async (req, res) => {
  const { cid } = req.query;
  try {
    const result = await pool.query('SELECT get_customer_summary($1) as summary', [cid]);
    if (result.rows.length > 0 && result.rows[0].summary !== null) {
      res.json({ summary: result.rows[0].summary });
    } else {
      res.status(404).json({ summary: 'לא נמצא תקציר עבור לקוח זה' });
    }
  } catch (err) {
    console.error('Error in get_customer_summary:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});

// נקודת קצה חדשה למוצרים פופולאריים
app.get('/api/popular-products', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT p.pname, SUM(op.amount) AS total_sold
      FROM product p
      JOIN purprod op ON p.pid = op.pid
      GROUP BY p.pname
      HAVING SUM(op.amount) > (SELECT AVG(amount) FROM purProd)
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching popular products:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});

// נקודת קצה חדשה ללקוחות החודש
app.get('/api/customers-this-month', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT c.cid, c.cname, c.cphone, o.purdate
      FROM customer c
      JOIN purchase o ON c.cid = o.cid
      WHERE EXTRACT(MONTH FROM o.purdate) = EXTRACT(MONTH FROM CURRENT_DATE)
      AND EXTRACT(YEAR FROM o.purdate) = EXTRACT(YEAR FROM CURRENT_DATE)
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching customers this month:', err);
    res.status(500).send('DB error: ' + err.message);
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});