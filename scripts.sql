CREATE TABLE users
(
    user_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         VARCHAR2(100) NOT NULL UNIQUE,
    password_hash VARCHAR2(255) NOT NULL,
    role          VARCHAR2(20) DEFAULT 'USER' CHECK (role IN ('USER', 'ADMIN')),
    creation_time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clients
(
    client_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id   NUMBER NOT NULL,
    name      VARCHAR2(100) NOT NULL,
    phone     VARCHAR2(20) NOT NULL
    CONSTRAINT clients_users_fk FOREIGN KEY (user_id) REFERENCES users (user_id),
);

CREATE TABLE locations
(
    location_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    address     VARCHAR2(255) NOT NULL,
    latitude    NUMBER(10,7) NOT NULL,
    longitude   NUMBER(10,7) NOT NULL
);

CREATE TABLE products
(
    product_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR2(50) NOT NULL,
    price      NUMBER(10,2) NOT NULL,
);

CREATE TABLE orders
(
    order_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    NUMBER NOT NULL,
    status     VARCHAR2(20) DEFAULT 'NEW'
        CHECK (status IN ('NEW','PREPARING','READY','ISSUED','CANCELLED')),
    creation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location_id NUMBER NOT NULL,
    CONSTRAINT orders_users_fk FOREIGN KEY (user_id) REFERENCES users (user_id)
    CONSTRAINT orders_locations_fk FOREIGN KEY (location_id) REFERENCES locations (location_id)
);

CREATE TABLE order_items
(
    item_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id   NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity   NUMBER DEFAULT 1,
    price      NUMBER(10,2) NOT NULL,
    CONSTRAINT order_items_orders_fk FOREIGN KEY (order_id) REFERENCES orders (order_id),
    CONSTRAINT order_items_products_fk FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- Процедура отмены заказа
CREATE
OR REPLACE PROCEDURE cancel_order(p_order_id IN NUMBER) AS
  v_status VARCHAR2(20);
BEGIN
SELECT status
INTO v_status
FROM orders
WHERE order_id = p_order_id;
IF
v_status = 'NEW' THEN
UPDATE orders
SET status = 'CANCELLED'
WHERE order_id = p_order_id;
COMMIT;
ELSE
    RAISE_APPLICATION_ERROR(-20001, 'Можно отменить только заказ со статусом "Новый"');
END IF;
END;

INSERT INTO products (name, price)
VALUES ('Бургер', 200.00),
       ('Пицца', 300.00),
       ('Чай', 100.00);

COMMIT;
