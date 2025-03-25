CREATE TABLE product
(
  pId NUMERIC(5) PRIMARY KEY,
  pName VARCHAR(15) NOT NULL,
  stock INT DEFAULT 0 CHECK (stock >= 0),
  Price FLOAT NOT NULL CHECK (Price >= 0),
  validity DATE CHECK (validity >= CURRENT_DATE)
);

CREATE TABLE employee
(
  eId NUMERIC(5) PRIMARY KEY,
  eName VARCHAR(15) NOT NULL,
  ePhone INT UNIQUE CHECK (ePhone >= 100000000 AND ePhone <= 999999999) -- מספר טלפון עם 9 ספרות
);

CREATE TABLE role
(
  rId NUMERIC(5) PRIMARY KEY,
  alias VARCHAR(15) NOT NULL,
  rStatus VARCHAR(10) DEFAULT 'active' CHECK (rStatus IN ('active', 'inactive', 'suspended')),
  eId NUMERIC(5),
  FOREIGN KEY (eId) REFERENCES employee(eId) ON DELETE SET NULL
);

CREATE TABLE orders  -- "order" היא מילה שמורה ב-SQL, לכן שיניתי ל-"orders"
(
  ordId NUMERIC(15) PRIMARY KEY,
  ordDate DATE DEFAULT CURRENT_DATE,
  ordStatus VARCHAR(10) NOT NULL CHECK (ordStatus IN ('ordered', 'shipped', 'delivered', 'cancelled')),
  ordCost INT NOT NULL CHECK (ordCost >= 0)
);

CREATE TABLE customer  -- תיקון שם הטבלה (costumer -> customer)
(
  cId NUMERIC(5) PRIMARY KEY,
  cName VARCHAR(15) NOT NULL,
  cPhone INT UNIQUE CHECK (cPhone >= 100000000 AND cPhone <= 999999999),
  ordId NUMERIC(15),
  FOREIGN KEY (ordId) REFERENCES orders(ordId) ON DELETE SET NULL
);

CREATE TABLE orderProd
(
  amount INT NOT NULL CHECK (amount > 0),
  pId NUMERIC(5),
  ordId NUMERIC(15),
  PRIMARY KEY (pId, ordId),
  FOREIGN KEY (pId) REFERENCES product(pId) ON DELETE CASCADE,
  FOREIGN KEY (ordId) REFERENCES orders(ordId) ON DELETE CASCADE
);

CREATE TABLE department
(
  depId NUMERIC(5) PRIMARY KEY,
  depName VARCHAR(15) NOT NULL,
  aisleNum INT NOT NULL CHECK (aisleNum > 0),
  pId NUMERIC(5),
  eId NUMERIC(5),
  FOREIGN KEY (pId) REFERENCES product(pId) ON DELETE SET NULL,
  FOREIGN KEY (eId) REFERENCES employee(eId) ON DELETE SET NULL
);

