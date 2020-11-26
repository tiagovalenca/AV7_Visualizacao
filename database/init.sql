CREATE SCHEMA olist;

CREATE TABLE olist.state_data(
  uf VARCHAR NOT NULL,
  state_name VARCHAR NOT NULL,
  capital VARCHAR NOT NULL,
  region VARCHAR NOT NULL,
  area DOUBLE PRECISION NOT NULL,
  population INT NOT NULL,
  demographic_density DOUBLE PRECISION NOT NULL,
  cities_count INT NOT NULL,
  GDP DOUBLE PRECISION NOT NULL,
  GDP_rate DOUBLE PRECISION NOT NULL,
  poverty DOUBLE PRECISION NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  CONSTRAINT state_pk
    PRIMARY KEY(uf)
);


CREATE TABLE olist.product_category_name_translation (
  product_category_name          VARCHAR  NOT NULL,
  product_category_name_english  VARCHAR  NOT NULL,
  CONSTRAINT product_category_name_translation_pk
    PRIMARY KEY (product_category_name)
);


CREATE TABLE olist.geolocation (
  geolocation_zip_code_prefix  VARCHAR           NOT NULL,
  geolocation_lat              DOUBLE PRECISION  NOT NULL,
  geolocation_lng              DOUBLE PRECISION  NOT NULL,
  geolocation_city             VARCHAR           NOT NULL,
  geolocation_state            VARCHAR           NOT NULL,
  CONSTRAINT geolocation_pk
    PRIMARY KEY (geolocation_zip_code_prefix, geolocation_city, geolocation_state),
  CONSTRAINT state_fk
    FOREIGN KEY (geolocation_state)
      REFERENCES olist.state_data (uf)
);


CREATE TABLE olist.customers (
  customer_id               UUID     NOT NULL,
  customer_unique_id        UUID     NOT NULL,
  customer_zip_code_prefix  VARCHAR  NOT NULL,
  customer_city             VARCHAR  NOT NULL,
  customer_state            VARCHAR  NOT NULL,
  CONSTRAINT customers_pk
    PRIMARY KEY (customer_id),
  CONSTRAINT customers_geolocation_fk
    FOREIGN KEY (customer_zip_code_prefix, customer_city, customer_state)
      REFERENCES olist.geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state)
);


CREATE TABLE olist.orders (
  order_id                       UUID       NOT NULL,
  customer_id                    UUID       NOT NULL,
  order_status                   VARCHAR    NOT NULL,
  order_purchase_timestamp       TIMESTAMP  NOT NULL,
  order_approved_at              TIMESTAMP  NOT NULL,
  order_delivered_carrier_date   TIMESTAMP  NOT NULL,
  order_delivered_customer_date  TIMESTAMP  NOT NULL,
  order_estimated_delivery_date  TIMESTAMP  NOT NULL,
  CONSTRAINT orders_pk
    PRIMARY KEY (order_id),
  CONSTRAINT orders_customers_fk
    FOREIGN KEY (customer_id)
      REFERENCES olist.customers (customer_id)
);


CREATE TABLE olist.products (
  product_id                  UUID     NOT NULL,
  product_category_name       VARCHAR  NOT NULL,
  product_name_lenght         VARCHAR  NOT NULL,
  product_description_lenght  INT      NOT NULL,
  product_photos_qty          INT      NOT NULL,
  product_weight_g            INT      NOT NULL,
  product_length_cm           INT      NOT NULL,
  product_height_cm           INT      NOT NULL,
  product_width_cm            INT      NOT NULL,
  CONSTRAINT products_pk
    PRIMARY KEY (product_id),
  CONSTRAINT products_product_category_name_translation_fk
    FOREIGN KEY (product_category_name)
      REFERENCES olist.product_category_name_translation (product_category_name)
);


CREATE TABLE olist.sellers (
  seller_id               UUID     NOT NULL,
  seller_zip_code_prefix  VARCHAR  NOT NULL,
  seller_city             VARCHAR  NOT NULL,
  seller_state            VARCHAR  NOT NULL,
  CONSTRAINT sellers_pk
    PRIMARY KEY (seller_id),
  CONSTRAINT sellers_geolocation_fk
    FOREIGN KEY (seller_zip_code_prefix, seller_city, seller_state)
      REFERENCES olist.geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state)
);


CREATE TABLE olist.order_payments (
  order_id              UUID     NOT NULL,
  payment_sequential    INT      NOT NULL,
  payment_type          VARCHAR  NOT NULL,
  payment_installments  INT      NOT NULL,
  payment_value         FLOAT    NOT NULL,
  CONSTRAINT order_payments_pk
    PRIMARY KEY (order_id),
  CONSTRAINT order_payments_orders_fk
    FOREIGN KEY (order_id)
      REFERENCES olist.orders (order_id)
);


CREATE TABLE olist.order_reviews (
  review_id                UUID       NOT NULL,
  order_id                 UUID       NOT NULL,
  review_score             INT        NOT NULL,
  review_comment_title     VARCHAR,
  review_comment_message   VARCHAR,
  review_creation_date     DATE       NOT NULL,
  review_answer_timestamp  TIMESTAMP  NOT NULL,
  CONSTRAINT order_reviews_pk
    PRIMARY KEY (review_id),
  CONSTRAINT order_reviews_orders_fk
    FOREIGN KEY (order_id)
      REFERENCES olist.orders (order_id)
);


CREATE TABLE olist.order_items (
  order_id             UUID       NOT NULL,
  order_item_id        INT        NOT NULL,
  product_id           UUID       NOT NULL,
  seller_id            UUID       NOT NULL,
  shipping_limit_date  TIMESTAMP  NOT NULL,
  price                FLOAT      NOT NULL,
  freight_value        FLOAT      NOT NULL,
  CONSTRAINT order_items_pk
    PRIMARY KEY (order_id),
  CONSTRAINT order_items_orders_fk
    FOREIGN KEY (order_id)
      REFERENCES olist.orders (order_id),
  CONSTRAINT order_items_products_fk
    FOREIGN KEY (product_id)
      REFERENCES olist.products (product_id),
  CONSTRAINT order_items_sellers_fk
    FOREIGN KEY (seller_id)
      REFERENCES olist.sellers (seller_id)
);

COPY olist.state_data(
  uf,
  state_name,
  capital,
  region,
  area,
  population,
  demographic_density,
  cities_count,
  GDP,
  GDP_rate,
  poverty,
  latitude,
  longitude
)
FROM '/var/lib/postgresql/states.csv'
DELIMITER ','
CSV HEADER;

COPY olist.product_category_name_translation(
  product_category_name,
  product_category_name_english
)
FROM '/var/lib/postgresql/product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;


COPY olist.geolocation(
  geolocation_zip_code_prefix,
  geolocation_lat,
  geolocation_lng,
  geolocation_city,
  geolocation_state
)
FROM '/var/lib/postgresql/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.customers(
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix,
  customer_city,
  customer_state
)
FROM '/var/lib/postgresql/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.orders(
  order_id,
  customer_id,
  order_status,
  order_purchase_timestamp,
  order_approved_at,
  order_delivered_carrier_date,
  order_delivered_customer_date,
  order_estimated_delivery_date
)
FROM '/var/lib/postgresql/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.products(
  product_id,
  product_category_name,
  product_name_lenght,
  product_description_lenght,
  product_photos_qty,
  product_weight_g,
  product_length_cm,
  product_height_cm,
  product_width_cm
)
FROM '/var/lib/postgresql/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.sellers(
  seller_id,
  seller_zip_code_prefix,
  seller_city,
  seller_state
)
FROM '/var/lib/postgresql/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.order_payments(
  order_id,
  payment_sequential,
  payment_type,
  payment_installments,
  payment_value
)
FROM '/var/lib/postgresql/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.order_reviews(
  review_id,
  order_id,
  review_score,
  review_comment_title,
  review_comment_message,
  review_creation_date,
  review_answer_timestamp
)
FROM '/var/lib/postgresql/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;


COPY olist.order_items(
  order_id,
  order_item_id,
  product_id,
  seller_id,
  shipping_limit_date,
  price,
  freight_value
)
FROM '/var/lib/postgresql/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;