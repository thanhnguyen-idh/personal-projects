USE project
GO
-----------------------------------------------------------
/*

CREATE TABLES AND INSERT DATA INTO TABLES

*/

------------ Create tables

CREATE TABLE tbl_room (
	id int PRIMARY KEY,
	room_type nvarchar(30) NOT NULL,
	capacity int NOT NULL,
	price decimal(10,3) NOT NULL,
	description nvarchar
)
GO

CREATE TABLE tbl_customer (
	id int PRIMARY KEY,
	customer_name nvarchar(50) NOT NULL,
	address nvarchar(100) NOT NULL,
	phone_number varchar(30) NOT NULL
)
GO

CREATE TABLE tbl_service (
	id int PRIMARY KEY,
	service_name nvarchar(200) NOT NULL,
	unit nvarchar(30) NOT NULL,
	price decimal(10,3) NOT NULL
)
GO

CREATE TABLE tbl_order (
	id int PRIMARY KEY,
	room_id int NOT NULL,
	customer_id int NOT NULL,
	order_date date NOT NULL,
	start_time time NOT NULL,
	end_time time NOT NULL,
	initial_deposit int NOT NULL,
	note nvarchar,
	status nvarchar(30) NOT NULL
)
GO

CREATE TABLE tbl_order_service (
	order_id int NOT NULL,
	service_id int NOT NULL,
	quantity int NOT NULL,
	PRIMARY KEY(order_id, service_id)
)
GO



----------- Add Constraints
ALTER TABLE tbl_order
ADD CONSTRAINT FK_order_room FOREIGN KEY (room_id) REFERENCES tbl_room(id),
	CONSTRAINT FK_order_customer FOREIGN KEY (customer_id) REFERENCES tbl_customer(id)
GO

ALTER TABLE tbl_order_service
ADD CONSTRAINT FK_order_service_order FOREIGN KEY (order_id) REFERENCES tbl_order(id),
	CONSTRAINT FK_order_service_service FOREIGN KEY (service_id) REFERENCES tbl_service(id)
GO



---------- Insert data into tables
INSERT INTO tbl_customer (id, customer_name, address, phone_number)
VALUES
(1, 'Nguyen Van A', 'Hoa Xuan', 111111),
(2, 'Pham Van B', 'Hoa Xuan', 222222),
(3, 'Doan Thi C', 'Ha Noi', 333333),
(4, 'Nguyen Van A', 'Bac Giang', 444444)

INSERT INTO tbl_room (id, room_type, capacity, price, description)
VALUES
(1, 'LOAI 1', 20, 60000, ''),
(2, 'LOAI 1', 25, 80000, ''),
(3, 'LOAI 2', 15, 50000, ''),
(4, 'LOAI 3', 20, 50000, '')

INSERT INTO tbl_service (id, service_name, unit, price)
VALUES
(1, 'Beer', 'bottle', 3000),
(2, 'Fruit', 'disk', 4000),
(3, 'Cigarette', 'pack', 2500),
(4, 'Wine', 'bottle', 5000)

INSERT INTO tbl_order (id, room_id, customer_id, order_date, start_time, end_time, initial_deposit, note, status)
VALUES
(1, 1, 2, '2023-05-26', '11:00:00', '13:00:00', 100000, '', 'completed'),
(2, 1, 3, '2023-05-27', '17:15:00', '19:15:00', 50000, '', 'canceled'),
(3, 2, 2, '2023-05-26', '20:30:00', '22:15:00', 100000, '', 'completed'),
(4, 3, 4, '2023-06-01', '19:30:00', '21:15:00', 200000, '', 'completed'),
(5, 3, 1, '2023-06-28', '13:30:00', '15:45:00', 150000, '', 'completed')

INSERT INTO tbl_order_service (order_id, service_id, quantity)
VALUES
(1, 1, 20),
(1, 2, 10),
(1, 3, 3),
(2, 2, 10),
(2, 3, 1),
(3, 3, 2),
(3, 4, 10)



-----------------------------------------------------------
/*

RETRIEVING DATA 

*/

-- 1: Liệt kê mã order, mã dịch vụ, số lượng của các dịch vụ có số lượng lớn hơn 3, nhỏ hơn 20
SELECT 
	  order_id
	, service_id
	, quantity
FROM 
	tbl_order_service
WHERE 
	quantity > 3 AND quantity < 20



-- 2: Cập nhật giá phòng mỗi phòng lên 10000 với những phòng có capacity < 25
UPDATE 
	tbl_room
SET 
	price = price + 10000
WHERE 
	capacity < 25



-- 3: Xóa những đơn đặt hàng bị canceled
DELETE FROM 
	tbl_order
WHERE 
	status = 'canceled'



-- 4: Liệt kê những tên khách hàng có tên bắt đầu là chữ 'N', 'P' và có độ dài tên không quá 20 ký tự
SELECT customer_name
FROM 
	tbl_customer
WHERE 
	customer_name LIKE '[NP]%' AND LEN(customer_name) < 20



-- 5: Liệt kê tất cả những khách hàng trong hệ thống, nếu tên nào trùng nhau chỉ hiển thị một lần
SELECT 
	customer_name
FROM 
	tbl_customer
GROUP BY 
	customer_name



-- 6: Liệt kê mã dịch vụ, tên dịch vụ, đơn vị, đơn giá của những dịch vụ có đơn vị là bottle và có đơn giá < 5000, HOẶC những dịch vụ có đơn vị là disk và có đơn giá > 3000
SELECT 
	  id
	, service_name
	, unit
	, price
FROM 
	tbl_service
WHERE 
	(unit='bottle' AND price < 5000) OR (unit='disk' AND price > 3000)



-- 7: Liệt kê mã order, mã phòng, loại phòng, capacity, giá phòng, mã khách hàng, số điện thoại, ngày order, giờ bắt đầu, giờ kết thúc, mã dịch vụ, số lượng và đơn giá 
------của những đơn trong tháng 5 và giá phòng > 50000
SELECT 
	  o.id
	, o.room_id
	, r.room_type
	, r.capacity
	, r.price
	, o.customer_id
	, c.phone_number
	, o.order_date
	, o.start_time
	, o.end_time
	, os.service_id
	, os.quantity
	, s.price as service_price
FROM 
	tbl_order as o
	LEFT JOIN tbl_room as r on o.room_id = r.id
	LEFT JOIN tbl_customer as c on o.customer_id = c.id
	LEFT JOIN tbl_order_service as os on o.id = os.order_id
	LEFT JOIN tbl_service as s on os.service_id = s.id
WHERE
	MONTH(o.order_date) = 5
	AND r.price > 50000



/*
8: Hiển thị mã order, mã phòng, loại phòng, giá phòng, tên khách, ngày order, OrderAmount, ServiceAmount, TotalAmount tương ứng với từng mã order có trong bảng order. 
Những đơn đặt phòng nào không sử dụng dịch vụ đi kèm thì cũng liệt kê thông tin của đơn đặt phòng đó ra.

OrderAmount = giá phòng * (Giờ kết thúc – Giờ bắt đầu)
ServiceAmount = số lượng * đơn giá
TotalAmount = OrderAmount + tổng tiền ServiceAmount
*/
SELECT
	  o.id
	, o.room_id
	, r.room_type
	, r.price as room_price
	, o.customer_id
	, o.order_date
	, r.price * (DATEDIFF(MINUTE, o.start_time, o.end_time)/60.0) as OrderAmount
	, ISNULL(SUM(os.quantity * s.price),0.0) as ServiceAmount
	, (r.price * (DATEDIFF(MINUTE, o.start_time, o.end_time)/60.0)) + ISNULL(sum(os.quantity * s.price),0.0) as TotalAmount
FROM
	tbl_order as o
	LEFT JOIN tbl_room as r on o.room_id = r.id
	LEFT JOIN tbl_order_service as os on o.id = os.order_id
	LEFT JOIN tbl_service as s on os.service_id = s.id
GROUP BY 
	  o.id
	, o.room_id
	, r.room_type
	, r.price
	, o.customer_id
	, o.order_date
	, r.price * (DATEDIFF(MINUTE, o.start_time, o.end_time)/60.0)



-- 9: Liệt kê mã khách hàng, tên khách hàng, địa chỉ, số điện thoại ĐÃ TỪNG đặt phòng và có địa chỉ ở 'Ha Noi'
SELECT
	  id
	, customer_name
	, address
	, phone_number
FROM 
	tbl_customer as c
WHERE 
	address = 'Ha Noi'
	AND EXISTS (
		SELECT o.customer_id
		FROM tbl_order as o
		WHERE o.customer_id = c.id)



-- 10: Liệt kê những mã phòng, loại phòng, capacity, giá phòng, số lần được đặt của những những phòng được đặt >=2 lần và trạng thái là completed
SELECT
	  r.id
	, room_type
	, capacity
	, price
	, COUNT(o.room_id) as Ordered_time
FROM 
	tbl_room as r
	LEFT JOIN tbl_order as o on o.room_id = r.id
WHERE
	o.status = 'completed'
GROUP BY
	  r.id
	, room_type
	, capacity
	, price
HAVING 
	COUNT(o.room_id) >=2