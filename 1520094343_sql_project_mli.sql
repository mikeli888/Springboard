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

-- Student: Chuen Li (Jun 2018)

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT f.name
FROM Facilities f
WHERE f.membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT f.facid, f.name, f.membercost, f.monthlymaintenance
FROM Facilities f
WHERE f.membercost > 0
and f.membercost < f.monthlymaintenance*0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT f.*
FROM Facilities f
where f.facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT f.name, f.monthlymaintenance,
  CASE WHEN f.monthlymaintenance > 100 THEN 'Expensive'
       ELSE 'Cheap' END AS 'Category'
FROM Facilities f

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT m.firstname, m.surname
FROM Members m
WHERE m.memid = 
  (SELECT MAX(memid) FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT f.name, CONCAT(m.surname, ' ', m.firstname) full_name
   FROM Members m,
        Facilities f,
        Bookings b
   WHERE f.name like 'Tennis Court%'
   and b.facid = f.facid
   AND m.memid = b.memid
GROUP BY 1,2
ORDER by 2,1

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

-- 1) get the cost (fac table) then 2) member info
-- output facility name, full member name, and the cost.
-- Order by descending cost,
SELECT f.name, CONCAT(m.surname, ' ', m.firstname) full_name, 
       CASE WHEN b.memid = 0 THEN f.guestcost ELSE f.membercost END AS total_cost 
       -- (f.guestcost + f.membercost) total_cost 
FROM Bookings b,
     Facilities f,
     Members m
WHERE b.starttime like '2012-09-14%'
AND CASE WHEN b.memid = 0 THEN f.guestcost ELSE f.membercost END > 30
AND f.facid = b.facid
AND m.memid = b.memid
ORDER BY 3 DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT res.facname, CONCAT(m.surname, ' ', m.firstname) full_name, 
       res.total_cost  
FROM Members m,
(SELECT f.name facname, b.memid,
       CASE WHEN b.memid = 0 THEN f.guestcost ELSE f.membercost END AS total_cost 
FROM Bookings b,
     Facilities f
WHERE b.starttime like '2012-09-14%'
AND CASE WHEN b.memid = 0 THEN f.guestcost ELSE f.membercost END > 30
AND f.facid = b.facid) res
WHERE res.memid = m.memid
ORDER BY 3 DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT facname facility_name, SUM(bookrev) total_revenue
FROM
(SELECT f.name facname, 
	    CASE WHEN b.memid = 0 THEN f.guestcost ELSE f.membercost END AS bookrev
FROM Bookings b,
     Facilities f
WHERE b.facid = f.facid) res
GROUP BY facname
HAVING SUM(bookrev) < 1000
ORDER BY 2
