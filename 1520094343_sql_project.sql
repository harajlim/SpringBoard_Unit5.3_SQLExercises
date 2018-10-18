/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name --get the names column
FROM Facilities 
WHERE membercost > 0 --facilities that do charge members, i.e membercost greater than 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( * ) --count all rows
FROM Facilities --Form Facilities
WHERE membercost =0 --That do not charge members

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance
AND membercost !=0 --since we don't want to include facilities that do not charge a fee to members

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM Facilities
WHERE facid IN ( 1, 5 ) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN  'expensive'
ELSE  'cheap'
END AS CheapOrExpensive
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate)FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT Facilities.name AS FacilityName,CONCAT(Members.firstname,' ',Members.surname) AS MemberWhoBooked 
FROM Bookings
LEFT JOIN Facilities
ON Facilities.facid=Bookings.facid
Left JOIN Members
ON Members.memid=Bookings.memid
WHERE Members.memid!=0 --since only considering members
AND Facilities.name LIKE 'Tennis Court%'
ORDER BY MemberWhoBooked
--Note that this is question can be a bit ambiguous. If I simply want a list of members who have used a tennis court,
-- The list would be shorter. However since we have to output the name of the court, and since some members have used more than one
--tennis court, I am forced to list the member twice; once in each court.




/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT Facilities.name AS FacilityName, 
CONCAT(Members.firstname,' ',Members.surname) AS MemberBooked, 
CASE WHEN Members.memid=0 THEN Bookings.slots*Facilities.guestcost
ELSE Bookings.slots*Facilities.membercost END AS PricePaid
FROM Bookings
Left JOIN Facilities
ON Facilities.facid=Bookings.facid
LEFT JOIN Members
ON Members.memid=Bookings.memid
WHERE Bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59' 
HAVING PricePaid > 30
Order By PricePaid DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT 

(SELECT Facilities.name As FacilityName FROM Facilities WHERE Facilities.facid=Bookings.facid) AS FacilityName,
(SELECT CONCAT (Members.firstname,' ',Members.surname) FROM Members WHERE Members.memid=Bookings.memid) AS BookerName,
CASE WHEN Bookings.memid=0 
THEN Bookings.slots*(SELECT Facilities.guestcost FROM Facilities where Facilities.facid=Bookings.facid) 
ELSE Bookings.slots*(SELECT Facilities.membercost FROM Facilities where Facilities.facid=Bookings.facid)
END AS PricePaid

FROM Bookings

WHERE Bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59' 
HAVING PricePaid>30
Order By PricePaid DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT Facilities.name AS FacilityName, 
CASE WHEN Bookings.memid=0 THEN SUM(Bookings.slots*Facilities.guestcost)
ELSE SUM(Bookings.slots*Facilities.membercost) END AS Revenue
FROM Bookings
Left JOIN Facilities
ON Facilities.facid=Bookings.facid
GROUP BY FacilityName
Having Revenue<1000
ORDER BY Revenue



