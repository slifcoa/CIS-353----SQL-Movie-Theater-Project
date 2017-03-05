
SET ECHO ON
/*
CIS 353 - Database Design Project
Bridget Bieniek
Joel Vander Klipp
Adam Slifco
Marcellus Chesebro
*/
/* The SQL/DDL code that creates your schema 
In the DDL, every IC must have a unique name; e.g. IC5, IC10, IC15, etc.*/
DROP TABLE Theater CASCADE CONSTRAINTS;
DROP TABLE Movie CASCADE CONSTRAINTS;
DROP TABLE Ticket CASCADE CONSTRAINTS;
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE ParkingSpace CASCADE CONSTRAINTS;
DROP TABLE Revenue CASCADE CONSTRAINTS;
DROP TABLE Showtime CASCADE CONSTRAINTS;
DROP TABLE Sells CASCADE CONSTRAINTS;
DROP TABLE ShownIn CASCADE CONSTRAINTS;

CREATE TABLE Theater(
theaterID INTEGER PRIMARY KEY,
seatingSize INTEGER);


CREATE TABLE Movie(
mID INTEGER PRIMARY KEY,
rating VARCHAR(10),
title VARCHAR(25),
description VARCHAR(140));


CREATE TABLE Ticket(
tID INTEGER PRIMARY KEY,
mID INTEGER,
cost INTEGER,
cAge INTEGER,
cName VARCHAR(20),
CONSTRAINT ATT1 CHECK (cost > 5),
CONSTRAINT KEY1 FOREIGN KEY (mID) REFERENCES Movie(mID)
);


CREATE TABLE Employee(
eID INTEGER PRIMARY KEY,
hours INTEGER,
name VARCHAR(20),
phoneNum INTEGER,
fullTimeStatus INTEGER,
super_eID INTEGER,
CONSTRAINT ATT3 CHECK ((fullTimeStatus = 1 AND hours > 25) OR (fullTimeStatus = 0 AND hours < 25)),
CONSTRAINT KEY3 FOREIGN KEY (super_eID) REFERENCES Employee(eID));


CREATE TABLE ParkingSpace(
parkID INTEGER PRIMARY KEY,
handicap INTEGER,
eID INTEGER,
CONSTRAINT KEY9 FOREIGN KEY (eID) REFERENCES Employee(eID));


CREATE TABLE Revenue(
amount INTEGER,
mID INTEGER,
mdate DATE,
PRIMARY KEY(mID, mdate),
CONSTRAINT KEY7 FOREIGN KEY (mID) REFERENCES Movie(mID));


CREATE TABLE Showtime(
mID INTEGER,
showTime VARCHAR(7),
PRIMARY KEY(mID, showTime),
CONSTRAINT KEY6 FOREIGN KEY (mID) REFERENCES Movie(mID));


CREATE TABLE Sells(
eID INTEGER,
tID INTEGER,
PRIMARY KEY(eID, tID),
CONSTRAINT KEY4 FOREIGN KEY (tID) REFERENCES Ticket(tID),
CONSTRAINT KEY5 FOREIGN KEY (eID) REFERENCES Employee(eID));


CREATE TABLE ShownIn(
type VARCHAR(10),
mID INTEGER,
theaterID INTEGER,
PRIMARY KEY(mID, theaterID),
CONSTRAINT KEY8 FOREIGN KEY (mID) REFERENCES Movie(mID),
CONSTRAINT KEY2 FOREIGN KEY (theaterID) REFERENCES Theater(theaterID));

SHOW ERROR

SET FEEDBACK OFF

INSERT INTO Movie VALUES (1, 'PG', 'Alice In Wonderland', 'Alice takes some acid and goes on a trip');
INSERT INTO Movie VALUES (2, 'R18', 'The Great Wolf', 'A wolf is suffering in the tundra and struggling to survive');

INSERT INTO Theater VALUES (10, 5);

INSERT INTO Ticket VALUES (101, 1, 15, 12, 'Rebecca');
INSERT INTO Ticket VALUES (102, 2, 20, 21, 'Jill');
INSERT INTO Ticket VALUES (103, 1, 15, 13, 'John');
INSERT INTO Ticket VALUES (104, 1, 15, 20, 'Sam');
INSERT INTO Ticket VALUES (105, 2, 20, 31, 'Rick');
INSERT INTO Ticket VALUES (106, 2, 20, 44, 'Morty');


INSERT INTO Employee VALUES(1001, 40, 'Mark Hamill', 1233211, 1, NULL);
INSERT INTO Employee VALUES(1002, 18, 'Luke Skywalker', 3211233, 0, 1001);
INSERT INTO Employee VALUES(1003, 17, 'John Jingle', 2421244, 0, 1001);

INSERT INTO ParkingSpace VALUES (250, 1, 1001);

INSERT INTO Revenue VALUES (1500, 2, TO_DATE('01/10/16', 'MM/DD/YYYY'));
INSERT INTO Revenue VALUES (1250, 2, TO_DATE('02/10/16', 'MM/DD/YYYY'));
INSERT INTO Revenue VALUES (1475, 1, TO_DATE('02/10/16', 'MM/DD/YYYY'));
INSERT INTO Revenue VALUES (1200, 1, TO_DATE('01/10/16', 'MM/DD/YYYY'));

INSERT INTO Showtime VALUES (1, '07:00PM');
INSERT INTO Showtime VALUES (1, '10:00PM');
INSERT INTO Showtime VALUES (2, '06:00PM');
INSERT INTO Showtime VALUES (2, '11:00AM');

INSERT INTO Sells VALUES (1001, 101);
INSERT INTO Sells VALUES (1002, 102);
INSERT INTO Sells VALUES (1002, 103);
INSERT INTO Sells VALUES (1003, 104);
INSERT INTO Sells VALUES (1003, 105);
INSERT INTO Sells VALUES (1003, 106);

INSERT INTO ShownIn VALUES ('regular',2, 10); 

SET FEEDBACK ON
COMMIT;

SELECT * FROM Movie;
SELECT * FROM Ticket;
SELECT * FROM Employee;
SELECT * FROM Revenue;
SELECT * FROM Theater;
SELECT * FROM ParkingSpace;
SELECT * FROM Showtime;
SELECT * FROM Sells;
SELECT * FROM ShownIn;

--Q1: TOP-N
--Finds the two employees that have worked the most hours
SELECT eID, name, hours 
FROM   (SELECT eID, name, hours 
        FROM   Employee
        ORDER BY hours DESC)
WHERE ROWNUM <= 2;

--Q2: GROUP BY
--finds the total cost of all tickets sold for each movie that has made 
--more than $50, and orders it by the sum of the cost.
SELECT T.mID, SUM(T.cost)
FROM Ticket T
GROUP BY T.mID
HAVING SUM(T.cost) > 50
ORDER BY SUM(T.cost);

--Q3: Self-join
--Finds employee and their supervisor 
SELECT DISTINCT E1.eID, E1.name, E2.eID, E2.name
FROM Employee E1, Employee E2 WHERE E1.super_eID = E2.eID;

--Q4: Non-correlated subquery
--Finds full time employees with parking spaces
SELECT eID, name FROM Employee WHERE fullTimeStatus = 1 AND eID 
IN (SELECT P.eID FROM ParkingSpace P);

--Q5: Rank query
--ranks the movies on how much they made on a particular date
SELECT mID, amount, mdate, RANK() OVER (PARTITION BY mdate ORDER BY amount DESC) "Daily Rank" 
FROM Revenue;

--Q6: Joining 4 Tables
--Finds the employees who have sold a ticket to an R-rated Movie
SELECT E.name, E.eID, T.tID, M.rating, M.title
FROM Employee E, Sells S, Ticket T, Movie M
WHERE E.eID = S.eID AND S.tID = T.tID And M.rating LIKE '%R18%'
ORDER BY E.name;

--Q7: Minus query
--Finds all the employees that have a parking space
SELECT E.eID, E.name, P.parkID
FROM Employee E, ParkingSpace P
MINUS
SELECT DISTINCT E.eID, E.name, P.parkID
FROM Employee E, ParkingSpace P
WHERE E.eID != P.eID;

--Q8: Correlated subquery
--Finds all the employees that have sold two or more tickets
SELECT E.eID, E.name
FROM Employee E
WHERE   (SELECT COUNT(*) 
	FROM Sells S 
	WHERE S.eID = E.eID) >= 2;

--Q9: Outer Join Query
--Finds the purchasing history of all tickets sold at the theater
SELECT M.mID, M.title, T.tID, T.cName, T.cost
FROM Movie M LEFT OUTER JOIN Ticket T ON M.mID = T.mID;

--Q10: Division query
--Finds all the employees that have sold tickets to every movie
SELECT E.eID, E.name
FROM Employee E
WHERE NOT EXISTS(SELECT M.mID 
	FROM Movie M
	MINUS
	SELECT DISTINCT T.mID
	FROM Ticket T, Sells S
	WHERE S.eID = E.eID AND T.tID = S.tID);

--Testing KEY1
INSERT INTO Ticket VALUES (104, 3, 20, 20, 'Sheryl');
--Testing ATT1
INSERT INTO Ticket VALUES (102, 2, 4, 45, 'Bob');
--Testing Primary Key
INSERT INTO Theater VALUES (NULL, 60000000);
--Testing ATT3
INSERT INTO Employee VALUES (1005, 20, 'Corey', NULL, 1, NULL);
INSERT INTO Employee VALUES (1004, 30, 'Joanne', NULL, 0, NULL);

COMMIT;

SPOOL OFF
