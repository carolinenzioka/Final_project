-----------------------------------CJ Boutique Hotel---------------------
-----------------------------------Caroline and Josh---------------------




/*works*/
CREATE TABLE addresses (
  address_ID  integer,
  address_line_one varchar(15),
  address_line_two varchar(15),
  city  varchar(15),
  state varchar(2),
  country varchar(50),
  CONSTRAINT address_pkey PRIMARY KEY (address_ID)
);
/*works*/
CREATE TABLE guest (
  guest_ID  integer,
  address_ID integer,
  first_name varchar(30) NOT NULL,
  middle_name varchar(30),
  last_name varchar(30),
  reward_balance money CHECK (reward_balance >= '0.00'),
  CONSTRAINT guest_pkey PRIMARY KEY (guest_ID),
    CONSTRAINT guest_fkey FOREIGN KEY (address_ID) REFERENCES addresses (address_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE
);

/*works*/
CREATE TABLE guest_contact_numbers (
  guest_ID  integer,
  guest_contact_numbers text[],
  phone_type varchar(15),
  CONSTRAINT guest_contact_numbers_pkey PRIMARY KEY (guest_ID, guest_contact_numbers),
    CONSTRAINT guest_contact_numbers_fkey FOREIGN KEY (guest_ID) REFERENCES guest (guest_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE
);

/*works*/
CREATE TABLE guest_email (
  guest_ID  integer,
  email varchar(50),
  email_rank integer,
  CONSTRAINT guest_email_pkey PRIMARY KEY (guest_ID, email),
    CONSTRAINT guest_email_fkey FOREIGN KEY (guest_ID) REFERENCES guest (guest_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE
);

/*works*/
CREATE TABLE cancellations (
  cancellation_ID integer,
  checkout_date date,
  arrival_date date,
  cancel_date date,
  CONSTRAINT cancellations_pkey PRIMARY KEY (cancellation_ID)
);

/*works*/
CREATE TABLE payment_info (
  payment_info_ID integer,
  tax_rate numeric(2,2) NOT NULL,
  subtotal money NOT NULL,
  tax_amount money NOT NULL,
  total_amount money NOT NULL,
  credit_card_number integer,
  expiration_date date,
  cvv integer,
  CONSTRAINT payment_info_pkey PRIMARY KEY (payment_info_ID)
);

/*works*/
CREATE TABLE staff (
  staff_ID  integer,
  staff_ID_manager integer,
  address_ID integer,
  first_name varchar(30) NOT NULL,
  middle_name varchar(30),
  last_name varchar(30),
  phone_num integer,
  email varchar(50),
  position varchar(50),
  ssn integer,
  birth_date date,
  CONSTRAINT staff_pkey PRIMARY KEY (staff_ID),
    CONSTRAINT staff_fkey1 FOREIGN KEY (staff_ID_manager) REFERENCES staff (staff_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE,
 CONSTRAINT staff_fkey2 FOREIGN KEY (address_ID) REFERENCES addresses (address_ID)
    ON DELETE CASCADE
          ON UPDATE CASCADE
);

/*works*/
CREATE TABLE hotel (
  hotel_ID  integer,
  address_ID integer,
  hotel_name varchar(30) NOT NULL,
  total_rooms integer,
  CONSTRAINT hotel_pkey PRIMARY KEY (hotel_ID),
    CONSTRAINT hotel_fkey FOREIGN KEY (address_ID) REFERENCES addresses (address_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE
);

/*works*/
CREATE TABLE hotel_contact_numbers (
  hotel_ID  integer,
  hotel_contact_numbers integer,
  phone_type varchar(15),
  CONSTRAINT hotel_contact_numbers_pkey PRIMARY KEY (hotel_ID, hotel_contact_numbers),
    CONSTRAINT hotel_contact_numbers_fkey FOREIGN KEY (hotel_ID) REFERENCES hotel (hotel_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE
);

/*works*/
CREATE TABLE hotel_email (
  hotel_ID  integer,
  email varchar(50),
  email_rank integer,
  CONSTRAINT hotel_email_pkey PRIMARY KEY (hotel_ID, email),
    CONSTRAINT hotel_email_fkey FOREIGN KEY (hotel_ID) REFERENCES hotel (hotel_ID)
      ON DELETE CASCADE
       ON UPDATE CASCADE
);

/*works*/
CREATE TABLE rooms (
  room_num_ID integer,
  hotel_ID integer,
  staff_ID_one integer,
  staff_ID_two integer,
  room_name varchar(50),
  room_type varchar(50),
  capacity integer,
  description varchar(100),
  room_status varchar(50),
  room_price money,
  CONSTRAINT rooms_pkey PRIMARY KEY (room_num_ID),
  CONSTRAINT rooms_fkey1 FOREIGN KEY (hotel_ID) REFERENCES hotel (hotel_ID)
    ON DELETE CASCADE
     ON UPDATE CASCADE,
  CONSTRAINT rooms_fkey2 FOREIGN KEY (staff_ID_one) REFERENCES staff (staff_ID)
      ON DELETE CASCADE
        ON UPDATE CASCADE,
  CONSTRAINT rooms_fkey3 FOREIGN KEY (staff_ID_two) REFERENCES staff (staff_ID)
      ON DELETE CASCADE
        ON UPDATE CASCADE
);

/*works*/
CREATE TABLE reservation (
  reservation_ID  integer,
  guest_ID integer,
  cancellation_ID integer,
  payment_info_ID integer,
  staff_ID integer,
  room_num_ID integer,
  arrival_date date,
  departure_date date,
  total_nights integer,
  adults integer,
  children integer,
  guest_notes varchar(500),
  is_available boolean,
  CONSTRAINT reservation_pkey PRIMARY KEY (reservation_ID),
  CONSTRAINT reservation_fkey1 FOREIGN KEY (guest_ID) REFERENCES guest (guest_ID)
    ON DELETE CASCADE
     ON UPDATE CASCADE,
  CONSTRAINT reservation_fkey2 FOREIGN KEY (cancellation_ID) REFERENCES cancellations (cancellation_ID)
      ON DELETE CASCADE
        ON UPDATE CASCADE,
  CONSTRAINT reservation_fkey3 FOREIGN KEY (payment_info_ID) REFERENCES payment_info (payment_info_ID)
      ON DELETE CASCADE
        ON UPDATE CASCADE,
  CONSTRAINT reservation_fkey4 FOREIGN KEY (staff_ID) REFERENCES staff (staff_ID)
        ON DELETE CASCADE
          ON UPDATE CASCADE,
  CONSTRAINT reservation_fkey5 FOREIGN KEY (room_num_ID) REFERENCES rooms (room_num_ID)
      ON DELETE CASCADE
        ON UPDATE CASCADE

);
------------------------------------------------------------------------------------------

















---------------------------------------Views---------------------------------------
-- let's create two views
-- creating a view to get details about currently staying guests at hotel


--1

create view currentGuestsAtHotel
as
select g.guest_ID, concat(g.first_name,' ',g.middle_name,' ', g.last_name) as guest_Name,
    r.reservation_ID, r.arrival_date, r.departure_date, r.total_nights,
    rm.room_num_ID, rm.room_name, rm.room_type, rm.capacity, rm.room_status, rm.room_price,
    rm.staff_ID_one, rm.staff_ID_two,
    h.hotel_ID, h.hotel_name,
    s.staff_ID_manager
from guest g
join reservation r on g.guest_ID = r.guest_ID
join rooms rm on r.room_num_ID = rm.room_num_ID
join staff s on rm.staff_ID_one = s.staff_ID
join hotel h on rm.hotel_ID = h.hotel_ID
join hotel_contact_numbers hcn on h.hotel_ID = hcn.hotel_ID
join hotel_email he on h.hotel_ID = he.hotel_ID
where r.arrival_date <= (select current_date)
and r.departure_date >= (select current_date);


-- to see details in this view use

select *from currentGuestsAtHotel;

-----------------------------------------------------------------------------------------------------------------

--2
--creating a view to find all the details of all the guests who ever stayed at the hotel
create view guestdetails as
select concat(g.first_name,' ',g.middle_name,' ', g.last_name) as guest_Name, gcn.guest_contact_numbers, ge.email,
r.reservation_id, r.arrival_date, r.departure_date, r.total_nights, r.is_available,
rm.room_name, rm.room_type, rm.room_price,
h.hotel_ID, h.hotel_name
from guest g
join reservation r on g.guest_ID = r.guest_ID
join rooms rm on r.room_num_ID = rm.room_num_ID
join hotel h on rm.hotel_ID = h.hotel_ID
join guest_contact_numbers gcn on g.guest_ID = gcn.guest_ID
join guest_email ge on g.guest_ID = ge.guest_ID
;

-----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------Functions--------------------------------------------

-- 1- This function is designed to calculate the number of employees the hotel has.

CREATE OR REPLACE FUNCTION totalemployees ()
RETURNS integer AS $count$
declare
	total integer;
BEGIN
   SELECT count(*) into total FROM staff;
   RETURN total;
END;
$count$ LANGUAGE plpgsql;

select totalemployees();

-----------------------------------------------------------------------------------------------------------------

--2- This function is used to select all the rooms that are between the price range given.

CREATE OR REPLACE FUNCTION get_room(Price_from int, Price_to int)
RETURNS varchar
LANGUAGE plpgsql
AS
$$
DECLARE
 room_selected varchar;
BEGIN
   SELECT room_name
   INTO room_selected
   FROM rooms
   WHERE room_price BETWEEN Price_from AND Price_to;
   RETURN room_selected;
End;
$$;

select get_room(100, 200);


-----------------------------------------------------------------------------------------------------------------
------------------------------------------------Trigger-----------------------------------------------------------------


-- 1- This trigger will calculate the total tax and the total amount to be paid by the customer. It will fire and update the results on the payment_info table. The example below will illustrate the process with a tax rate of 12%


CREATE OR REPLACE FUNCTION total_price()
RETURNS TRIGGER
AS $$
DECLARE
	total numeric;
	total_tax numeric;
	BEGIN
	total_tax = new.tax_rate * new.subtotal;
	new.tax_amount = total_tax;
	total = (new.tax_rate * new.subtotal) + new.subtotal;
	new.total_amount = total;
	RETURN NEW;
END;
$$ language plpgsql;


CREATE TRIGGER calculations
BEFORE INSERT
ON payment_info
FOR EACH ROW
EXECUTE PROCEDURE total_price();

INSERT INTO payment_info VALUES (103, 0.12, 500, 567898765, 2020-05-06, 345 );
select * FROM payment_info


-----------------------------------------------------------------------------------------------------------------

--Procedure
-- now creating a Procedure
-- changing the position of staff, can be used to promote or demote an employee,

CREATE OR REPLACE PROCEDURE Updatestaff_Position
(
    empposition varchar (50),
	empstaff_ID integer
)
LANGUAGE plpgsql AS
$$
BEGIN
   UPDATE staff SET
   position = empposition
   Where staff_Id = empstaff_Id;
END
$$;

-- Call this procedure using,
call Updatestaff_Position ('Asst.Manager', 24);


-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------Queries-----------------------------------------------------------


-- writing query to find number of cancellations

select g.guest_ID, concat(g.first_name,' ',g.middle_name,' ', g.last_name) as guest_Name, r.reservation_id, c.cancellation_id from guest g
join reservation r on g.guest_id = r.guest_id
join cancellations c on r.cancellation_id = c.cancellation_id;


-----------------------------------------------------------------------------------------------------------------


--writing query to find cheapest and most expensive room

select room_num_id, room_name, room_type, room_price from rooms
where room_price =(select max(room_price) from rooms)
or room_price  =(select min(room_price) from rooms)
order by room_price;


-----------------------------------------------------------------------------------------------------------------


--writing query to find details of rooms available

select * from rooms where room_num_id not in (select room_num_id
                                             from reservation
                                             where arrival_date <= (select CURRENT_DATE)
                                             and departure_date >= (select CURRENT_DATE));









-----------------------------------------------------------------------------------------------------------------


--query to find which staff served which guest

select g.guest_ID, concat(g.first_name,' ',g.middle_name,' ', g.last_name) as guest_Name, concat(s.first_name,' ',s.middle_name,' ', s.last_name) as staff_Name
from guest g
join reservation r on g.guest_ID = r.guest_ID
join staff s on r.staff_ID = s.staff_ID;

-----------------------------------------------------------------------------------------------------------------
--This Query is designed to give each rewards member a title. This helps the hotel know what amenities to give the guests when they arrive.

SELECT first_name, middle_name, last_name, guest_ID,
CASE
WHEN reward_balance < ‘1000’ THEN 'BRONZE MEMBER'
WHEN ((reward_balance >= ‘1000’) AND (reward_balance <= ‘10000’)) THEN 'GOLD MEMBER'
ELSE 'PLATINUM MEMBER'
END AS guest_status
FROM guest;


--------------------------------------------------------------------------------------------------------------------

--INSERT STATEMENTS
--Addresses table done--
INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('1','4122','Charla Lane','Mesquite','TX','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('2','3714', 'Daylene Drive','Michigan','MI','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('3','538','Lochmere Lane','Connecticut','CT','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('4','1493','Ashton Lane','Austin','TX','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('5','2829','Ridenour Street','Miami','FL','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('65','4772','Irving Place','Overland','MO','US');

--Staff Addresses--
INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('81','1070','Eden Drive','Richmond','VA','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('82','4101','Bluff Street','Annapolis','MD','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('83','678','Hinkle Deegan','Masonville','NY','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('84','1703','Apple Lane','Peoria','IL','US');

INSERT INTO addresses (address_ID,address_line_one,address_line_two,city,state,country)
VALUES ('85','1861','Clover Drive','The Springs','CO','US');



--Cancellations table done--
INSERT INTO cancellations (cancellation_ID,checkout_date,arrival_date,cancel_date)
VALUES ('6', date '2022-02-09',date '2022-01-09', date '2022-01-25');

INSERT INTO cancellations (cancellation_ID,checkout_date,arrival_date,cancel_date)
VALUES ('7', date '2022-04-09',date '2022-03-09', date '2022-03-25');

INSERT INTO cancellations (cancellation_ID,checkout_date,arrival_date,cancel_date)
VALUES ('8', date '2022-06-09',date '2022-05-09', date '2022-05-25');

INSERT INTO cancellations (cancellation_ID,checkout_date,arrival_date,cancel_date)
VALUES ('9', date '2022-08-09',date '2022-07-09', date '2022-07-25');

INSERT INTO cancellations (cancellation_ID,checkout_date,arrival_date,cancel_date)
VALUES ('10', date '2022-10-09',date '2022-09-09', date '2022-09-25');

--Guest table done--
INSERT INTO guest (guest_ID,address_ID,first_name,middle_name,last_name,reward_balance)
VALUES ('11', '1','Audrey','R','Abdo',100);

INSERT INTO guest (guest_ID,address_ID,first_name,middle_name,last_name,reward_balance)
VALUES ('12', '2','Allie','L','Oboyle',200);

INSERT INTO guest (guest_ID,address_ID,first_name,middle_name,last_name,reward_balance)
VALUES ('13', '3','John','B','Johnson',300);

INSERT INTO guest (guest_ID,address_ID,first_name,middle_name,last_name,reward_balance)
VALUES ('14', '4','Rovert','M','Stephens',400);

INSERT INTO guest (guest_ID,address_ID,first_name,middle_name,last_name,reward_balance)
VALUES ('15', '5','William','O','Neil',500);

--Guest Contact Numbers table--
INSERT INTO guest_contact_numbers (guest_ID, guest_contact_numbers,phone_type)
VALUES ('11','48029291','Mobile');

INSERT INTO guest_contact_numbers (guest_ID, guest_contact_numbers,phone_type)
VALUES ('12','25664236','Mobile');

INSERT INTO guest_contact_numbers (guest_ID, guest_contact_numbers,phone_type)
VALUES ('13','61266947','Mobile');

INSERT INTO guest_contact_numbers (guest_ID, guest_contact_numbers,phone_type)
VALUES ('14','40650587','Home');

INSERT INTO guest_contact_numbers (guest_ID, guest_contact_numbers,phone_type)
VALUES ('15','41930965','Home');

--Guest Email Table done--
INSERT INTO guest_email (guest_ID, email,email_rank)
VALUES ('11','lavinia_fa5@hotmail.com','1');

INSERT INTO guest_email (guest_ID, email,email_rank)
VALUES ('12','te.quitzo0@yahoo.com','2');

INSERT INTO guest_email (guest_ID, email,email_rank)
VALUES ('13','weston.waelc@gmail.com','3');

INSERT INTO guest_email (guest_ID, email,email_rank)
VALUES ('14','alverta_cai4@gmail.com','4');

INSERT INTO guest_email (guest_ID, email,email_rank)
VALUES ('15','jayda1996@yahoo.com','5');

--Hotel Email Table Done --
INSERT INTO hotel (hotel_ID, address_ID,hotel_name, total_rooms)
VALUES ('16','65','CandJHotel','5');

--Hotel Contact Numbers Table Done--
INSERT INTO hotel_contact_numbers(hotel_ID, hotel_contact_numbers, phone_type)
VALUES ('16', ARRAY['7042650737','8109192509'],'office');

--Hotel Email Table Done--
INSERT INTO hotel_email(hotel_ID, email, email_rank)
VALUES('16','CandJHotel@gmail.com','1');

--Payment Info Table Done--
INSERT INTO payment_info(payment_info_ID,tax_rate,subtotal,tax_amount,total_amount,credit_card_number,expiration_date,cvv)
VALUES('17','0.25','20.21','0.050525','20.260525','451300','2022-12-12','246');

INSERT INTO payment_info(payment_info_ID,tax_rate,subtotal,tax_amount,total_amount,credit_card_number,expiration_date,cvv)
VALUES('18','0.25','20.21','0.050525','20.260525','4523198','2024-03-06','849');

INSERT INTO payment_info(payment_info_ID,tax_rate,subtotal,tax_amount,total_amount,credit_card_number,expiration_date,cvv)
VALUES('19','0.25','20.21','0.050525','20.260525','453138','2024-07-29','117');

INSERT INTO payment_info(payment_info_ID,tax_rate,subtotal,tax_amount,total_amount,credit_card_number,expiration_date,cvv)
VALUES('20','0.25','20.21','0.050525','20.260525','4009423','2024-09-12','526');

INSERT INTO payment_info(payment_info_ID,tax_rate,subtotal,tax_amount,total_amount,credit_card_number,expiration_date,cvv)
VALUES('21','0.25','20.21','0.050525','20.260525','530285','2025-10-25','171');


--Staff Table Done--
INSERT INTO staff(staff_ID,address_ID,first_name,middle_name,last_name,phone_num,email,position,ssn)
VALUES(22,81,'Patrick','L','Johnson','434939','leonard.schuli@hotmail.com','Manager','19870127');

INSERT INTO staff(staff_ID,address_ID,first_name,middle_name,last_name,phone_num,email,position,ssn,birth_date)
VALUES(23,82,'Leonard','L','Henry','719358','aron1984@hotmail.com','Hotel Porter','650169057','1989-06-30');

INSERT INTO staff(staff_ID,address_ID,first_name,middle_name,last_name,phone_num,email,position,ssn,birth_date)
VALUES(24,83,'Myra','S','Wilson','6102235','leo_christians@yahoo.com','Hotel Porter','198349529','1990-01-16');

INSERT INTO staff(staff_ID,address_ID,first_name,middle_name,last_name,phone_num,email,position,ssn,birth_date)
VALUES(25,84,'Sharon','A','Storey','813416','leo_christians@yahoo.com','Hotel Porter','767425563','1975-08-28');

INSERT INTO staff(staff_ID,address_ID,first_name,middle_name,last_name,phone_num,email,position,ssn,birth_date)
VALUES(26,84,'Douglas','B','Scott','412443','harry1982@gmail.com','Hotel Porter','168500812','1991-08-21');

--Rooms Table Done--
INSERT INTO rooms(room_num_ID,hotel_ID,staff_ID_one,staff_ID_two,room_name,room_type,capacity,room_price)
VALUES(27,16,22,23,'The Platinum Room','Luxury Suite','6',1000);

INSERT INTO rooms(room_num_ID,hotel_ID,staff_ID_one,staff_ID_two,room_name,room_type,capacity,description,room_status,room_price)
VALUES(28,16,26,25,'The Diamond Room','Semi-Luxury Suite','5','This is the second best room to the luxury suite.','Available',800);

INSERT INTO rooms(room_num_ID,hotel_ID,staff_ID_one,staff_ID_two,room_name,room_type,capacity,description,room_status,room_price)
VALUES(29,16,24,23,'The Gold Room','King Suite','4','This is the third best room to the Diamond Room.','Available',600);

INSERT INTO rooms(room_num_ID,hotel_ID,staff_ID_one,staff_ID_two,room_name,room_type,capacity,description,room_status,room_price)
VALUES(30,16,23,26,'The Silver Room','Queen Suite','4','This is the fourth best room to the Diamond Room.','Available',400);

INSERT INTO rooms(room_num_ID,hotel_ID,staff_ID_one,staff_ID_two,room_name,room_type,capacity,description,room_status,room_price)
VALUES(31,16,22,26,'The Bronze Room','Junior Suite','3','This is the fifth best room to the Diamond Room.','Available',200);


--Reservation Table Done--
INSERT INTO reservation(reservation_ID,guest_ID,cancellation_ID,payment_info_ID,staff_ID,room_num_ID,arrival_date,departure_date,total_nights,adults,children,guest_notes,is_available)
VALUES(32,11,6,17,22,27,date '2022-01-09', date '2022-02-09',29,2,1,'N/A',TRUE);

INSERT INTO reservation(reservation_ID,guest_ID,cancellation_ID,payment_info_ID,staff_ID,room_num_ID,arrival_date,departure_date,total_nights,adults,children,guest_notes,is_available)
VALUES(33,12,7,18,23,28,date '2022-03-09', date '2022-04-09',29,2,3,'N/A',FALSE);

INSERT INTO reservation(reservation_ID,guest_ID,cancellation_ID,payment_info_ID,staff_ID,room_num_ID,arrival_date,departure_date,total_nights,adults,children,guest_notes,is_available)
VALUES(34,13,8,19,24,29,date '2022-05-09', date '2022-06-09',29,2,4,'N/A',FALSE);

INSERT INTO reservation(reservation_ID,guest_ID,cancellation_ID,payment_info_ID,staff_ID,room_num_ID,arrival_date,departure_date,total_nights,adults,children,guest_notes,is_available)
VALUES(35,14,9,20,25,30,date '2022-07-09', date '2022-08-09',29,1,3,'N/A',TRUE);

INSERT INTO reservation(reservation_ID,guest_ID,cancellation_ID,payment_info_ID,staff_ID,room_num_ID,arrival_date,departure_date,total_nights,adults,children,guest_notes,is_available)
VALUES(36,15,10,21,26,31,date '2022-09-09', date '2022-10-09',29,2,2,'N/A',TRUE);
