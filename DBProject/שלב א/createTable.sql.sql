CREATE TABLE department (
  depId NUMERIC(5) PRIMARY KEY,
  depName VARCHAR(30) NOT NULL,
  aisleNum INT NOT NULL CHECK (aisleNum > 0)
);

CREATE TABLE role (
  rId NUMERIC(5) PRIMARY KEY,
  alias VARCHAR(30) NOT NULL,
  rStatus VARCHAR(10) DEFAULT 'active' CHECK (rStatus IN ('active', 'inactive', 'suspended'))
);

CREATE TABLE customer (  -- תיקון שם (costumer -> customer)
  cId NUMERIC(5) PRIMARY KEY,
  cName VARCHAR(15) NOT NULL,
  cPhone NUMERIC(12) UNIQUE CHECK (cPhone >= 100000000000 AND cPhone <= 999999999999)  -- טלפון עם 12 ספרות
);

CREATE TABLE product (
  pId NUMERIC(5) PRIMARY KEY,
  pName VARCHAR(30) NOT NULL,
  stock INT DEFAULT 0 CHECK (stock >= 0),
  price FLOAT NOT NULL CHECK (price >= 0),
  validity DATE CHECK (validity >= CURRENT_DATE),
  depId NUMERIC(5) NOT NULL,
  FOREIGN KEY (depId) REFERENCES department(depId) ON DELETE CASCADE
);

CREATE TABLE employee (
  eId NUMERIC(5) PRIMARY KEY,
  eName VARCHAR(15) NOT NULL,
  ePhone NUMERIC(12) UNIQUE CHECK (ePhone >= 100000000000 AND ePhone <= 999999999999),  -- טלפון עם 12 ספרות
  depId NUMERIC(5) NOT NULL,
  rId NUMERIC(5) NOT NULL,
  FOREIGN KEY (depId) REFERENCES department(depId) ON DELETE SET NULL,
  FOREIGN KEY (rId) REFERENCES role(rId) ON DELETE SET NULL
);

CREATE TABLE orders (  -- "order" היא מילה שמורה ב-SQL, לכן שיניתי ל-"orders"
  ordId NUMERIC(5) PRIMARY KEY,
  ordDate DATE DEFAULT CURRENT_DATE,
  ordStatus VARCHAR(10) NOT NULL CHECK (ordStatus IN ('ordered', 'shipped', 'delivered', 'cancelled')),
  ordCost INT NOT NULL CHECK (ordCost >= 0),
  cId NUMERIC(5) NOT NULL,
  FOREIGN KEY (cId) REFERENCES customer(cId) ON DELETE CASCADE
);

CREATE TABLE orderProd (
  amount INT NOT NULL CHECK (amount > 0),
  pId NUMERIC(5) NOT NULL,
  ordId NUMERIC(5) NOT NULL,
  PRIMARY KEY (pId, ordId),
  FOREIGN KEY (pId) REFERENCES product(pId) ON DELETE CASCADE,
  FOREIGN KEY (ordId) REFERENCES orders(ordId) ON DELETE CASCADE
);
