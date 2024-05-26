CREATE DATABASE  IF NOT EXISTS `aditya_ecom`
USE `aditya_ecom`;
DROP TABLE IF EXISTS `product_items`;
CREATE TABLE `product_items` (
  `item_id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`item_id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
  LOCK TABLES `product_items` WRITE;
  INSERT INTO `product_items` VALUES (1,'Shorts',78.00),(2,'Cartoon Astronaut T-Shirt',78.00),(3,' Cotton-Jersey Zip-Up Hoodie',78.00);
  UNLOCK TABLES;
  CREATE TABLE `order_tracking` (
  `order_id` int NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
LOCK TABLES `order_tracking` WRITE;
INSERT INTO `order_tracking` VALUES (40,'delivered'),(41,'in transit');
UNLOCK TABLES;
CREATE TABLE `orders` (
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`item_id`),
  KEY `orders_ibfk_1` (`item_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `product_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
LOCK TABLES `orders` WRITE;
INSERT INTO `orders` VALUES (40,1,2,156.00),(40,3,1,78.00),(41,2,3,234.00),(41,1,2,156.00),(42,2,4,312.00);
UNLOCK TABLES;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_price_for_item`(p_item_name VARCHAR(255)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_price DECIMAL(10, 2);
    
    -- Check if the item_name exists in the food_items table
    IF (SELECT COUNT(*) FROM product_items WHERE name = p_item_name) > 0 THEN
        -- Retrieve the price for the item
        SELECT price INTO v_price
        FROM product_items
        WHERE name = p_item_name;
        
        RETURN v_price;
    ELSE
        -- Invalid item_name, return -1
        RETURN -1;
    END IF;
END ;;
DELIMITER ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_total_order_price`(p_order_id INT) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_total_price DECIMAL(10, 2);
    
    -- Check if the order_id exists in the orders table
    IF (SELECT COUNT(*) FROM orders WHERE order_id = p_order_id) > 0 THEN
        -- Calculate the total price
        SELECT SUM(total_price) INTO v_total_price
        FROM orders
        WHERE order_id = p_order_id;
        
        RETURN v_total_price;
    ELSE
        -- Invalid order_id, return -1
        RETURN -1;
    END IF;
END ;;
DELIMITER ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_order_item`(
  IN p_product_item VARCHAR(255),
  IN p_quantity INT,
  IN p_order_id INT
)
BEGIN
    DECLARE v_item_id INT;
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_total_price DECIMAL(10, 2);

    -- Get the item_id and price for the food item
    SET v_item_id = (SELECT item_id FROM product_items WHERE name = p_product_item);
    SET v_price = (SELECT get_price_for_item(p_product_item));

    -- Calculate the total price for the order item
    SET v_total_price = v_price * p_quantity;

    -- Insert the order item into the orders table
    INSERT INTO orders (order_id, item_id, quantity, total_price)
    VALUES (p_order_id, v_item_id, p_quantity, v_total_price);
END ;;
DELIMITER ;
