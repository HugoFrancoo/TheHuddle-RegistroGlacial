CREATE TABLE customers(
    customer_id INTEGER NOT NULL PRIMARY KEY,
    full_name VARCHAR(80),
    email VARCHAR(80),
    phone VARCHAR(80),
    created_at TIMESTAMP,
    is_active BOOLEAN NOT NULL,
    deleted_at TIMESTAMP

    CONSTRAINT fk_city
        FOREIGN KEY (city_id)
        REFERENCES city(city_id),
    CONSTRAINT fk_segment
        FOREIGN KEY (segment_id)
        REFERENCES segment(segment_id)
);

CREATE TABLE orders(
    order_id INTEGER NOT NULL PRIMARY KEY,
    order_datetime TIMESTAMP,
    is_active BOOLEAN NOT NULL,
    deleted_at TIMESTAMP,
    order_total NUMERIC

    CONSTRAINT fk_customer_id
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT fk_channel_id
        FOREIGN KEY (channel_id)
        REFERENCES channel(channel_id),
    CONSTRAINT fk_current_status_id
        FOREIGN KEY (current_status_id)
        REFERENCES current_status(current_status_id),
    CONSTRAINT fk_currency_id
        FOREIGN KEY (currency_id)
        REFERENCES currency(currency_id)
);

CREATE TABLE order_status_history (
    order_status_history INTEGER NOT NULL PRIMARY KEY,

    changed_at TIMESTAMP,

    CONSTRAINT fk_order 
        FOREIGN KEY (order_id)
        REFERENCES order(order_id),
    CONSTRAINT fk_status
        FOREIGN KEY (status_id)
        REFERENCES status(status_id),
    CONSTRAINT fk_changed_by
        FOREIGN KEY (changed_by_id)
        REFERENCES changed_by(changed_by_id),
    CONSTRAINT fk_reason
        FOREIGN KEY (reason_id)
        REFERENCES reason(reason_id)

)