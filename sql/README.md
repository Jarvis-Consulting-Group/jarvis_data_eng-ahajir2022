
# PSQL Database management:

- Create and manipulate data of a PSQL database.

As a first step of conception, we create ERD (Entity Relationship Diagram) Composed of 3 Entities (tables)

-- Members -- Bookings -- Facilities

 --- Insert here link to png ERD


 -- First steps to verify before proceeding to the creation of entities

### Check if the spql container is already running
    docker ps -a

### start the container if necesary
    docker start jrvs-psql

### run psql instance
    psql -h localhost -U postgres -d postgres -W



### CREATE a DATABASE :  exercises
    CREATE DATABASE exercises;

### switch to the database exercixes (IN TERMINAL) OR USE psql PGADMIN
    \c exercises

### create a schema called cd
    CREATE SCHEMA cd;

### switch to the schema cd
    SET search_path = cd;

### CREATE A TABLE MEMBERS
    CREATE TABLE cd.members
    (
    memid integer NOT NULL,
    surname character varying(200) NOT NULL,
    firstname character varying(200) NOT NULL,
    address character varying(300) NOT NULL,
    zipcode integer NOT NULL,
    telephone character varying(20) NOT NULL,
    recommendedby integer,
    joindate timestamp NOT NULL,
    CONSTRAINT members_pk PRIMARY KEY (memid),
    CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
        REFERENCES cd.members(memid) ON DELETE SET NULL
    );

### CREATE TABLE FACILITIES
    CREATE TABLE cd.facilities
    (
    facid integer NOT NULL,
    name character varying(100) NOT NULL,
    membercost numeric NOT NULL,
    guestcost numeric NOT NULL,
    initialoutlay numeric NOT NULL,
    monthlymaintenance numeric NOT NULL,
    CONSTRAINT facilities_pk PRIMARY KEY (facid)
    );

### CREATE TABLE BOOKINGS
    CREATE TABLE cd.bookings
    (
    bookid integer NOT NULL,
    facid integer NOT NULL,
    memid integer NOT NULL,
    starttime timestamp NOT NULL,
    slots integer NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (bookid),
    CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
    );

## Modifying Data
### Insert some data into a table FACILITIES (The club is adding a new facility - a spa. We need to add it into the facilities table)
    INSERT INTO cd.facilities(
      facid, Name, membercost, guestcost, 
      initialoutlay, monthlymaintenance
      ); 
    VALUES 
     (9, 'Spa', 20, 30, 100000, 800);
  
#### display of results will be as follows - the line 9 has been added to the results:

```
| facid | name             | membercost | guestcost | initialoutlay | monthlymaintenance |
|-------|------------------|------------|-----------|---------------|-------------------|
| 0     | Tennis Court 1   | 5          | 25        | 10000         | 200               |
| 1     | Tennis Court 2   | 5          | 25        | 8000          | 200               |
| 2     | Badminton Court  | 0          | 15.5      | 4000          | 50                |
| 3     | Table Tennis     | 0          | 5         | 320           | 10                |
| 4     | Massage Room 1   | 35         | 80        | 4000          | 3000              |
| 5     | Massage Room 2   | 35         | 80        | 4000          | 3000              |
| 6     | Squash Court     | 3.5        | 17.5      | 5000          | 80                |
| 7     | Snooker Table    | 0          | 5         | 450           | 15                |
| 8     | Pool Table       | 0          | 5         | 400           | 15                |
| 9     | Spa              | 20         | 30        | 100000        | 800               |

```


### Update some existing data (We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000)
    UPDATE 
      cd.facilities 
    SET 
      initialoutlay = 10000 
    WHERE 
      facid = '1';
  

### Insert calculated data into a table (we want to automatically generate the value for the next facid, rather than specifying it as a constant - modify Spa)
    insert into cd.facilities(
      facid, name, membercost, guestcost, 
       initialoutlay, monthlymaintenance
     ) 
    select 
    (
    select 
      max(facid) 
    from 
      cd.facilities
      )+ 1, 
     'Spa', 
     20, 
     30, 
     100000, 
     800;
  
### Update a row based on the contents of another row (alter the price of the second tennis court so that it costs 10% more than the first one)
    --- update cost for members
    update 
    cd.facilities 
    set 
     membercost =(
    select 
      membercost * 1.1 
    FROM 
      cd.facilities 
    where 
      facid = '0'
     ) 
     WHERE 
     facid = '1';
	
   --- update cost for guests
     update 
      cd.facilities 
    set 
    guestcost =(
    select 
      guestcost * 1.1 
    FROM 
      cd.facilities 
    where 
      facid = '0'
     ) 
     WHERE 
      facid = '1';



### DELETE ALL BOOKINGS
    TRUNCATE cd.bookings;


### DELETE MEMBER 37
    DELETE FROM cd.members WHERE memid='37';

## Basics

### Control which rows are retrieved - (How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.)
    select 
     facid, 
     name, 
     membercost, 
     monthlymaintenance 
    from 
     cd.facilities 
    where 
      membercost != 0 
      and membercost < monthlymaintenance / 50;


### Basic string searches (How can you produce a list of all facilities with the word 'Tennis' in their name?)
    SELECT
      * 
    FROM 
    cd.facilities 
    WHERE 
    name LIKE '%Tennis%';
    
### Matching against multiple possible values (How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.)

    SELECT 
     * 
    FROM 
     cd.facilities 
    WHERE facid
     IN (1, 5);
	
### Working with dates (How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.)
    SELECT 
      * 
    FROM 
     members 
    WHERE 
      joindate > '2012-09-01';

### Combining results from multiple queries (combined list of all surnames and all facility names)

    SELECT 
      surname 
    FROM 
      cd.members 
    UNION 
    SELECT 
     name 
    FROM 
     cd.facilities;


### Retrieve the start times of members bookings (List of the start times for bookings by members named "David Farrell"?).
    SELECT 
      bc.starttime 
    from 
      cd.bookings bc 
      inner join cd.members memb on memb.memid = bc.memid 
    where 
      memb.firstname = 'David' 
      and memb.surname = 'Farrell';


### Work out the start times of bookings for tennis courts (produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.)

    select bks.starttime as start, facs.name as name
	from 
		cd.facilities facs
		inner join cd.bookings bks
			on facs.facid = bks.facid
	where 
		facs.name in ('Tennis Court 2','Tennis Court 1') and
		bks.starttime between '2012-09-21' and '2012-09-22'
    order by bks.starttime;  


### Produce a list of all members, along with their recommender (output a list of all members, including the individual who recommended them (if any) - ordered by (surname, firstname))

    SELECT 
       m.firstname membfname, 
       m.surname membname, 
       mr.firstname refsname, 
       mr.surname refname 
    FROM 
      cd.members m 
      LEFT JOIN cd.members mr ON mr.memid = m.recommendedby 
    ORDER BY 
      membname, 
      membfname;


### Produce a list of all members who have recommended another member (output a list of all members who have recommended another member -  with no duplicates in the list, and that results are ordered by (surname, firstname).)
    SELECT 
     DISTINCT rec.firstname, 
     rec.surname 
    from 
     cd.members mem 
     inner join cd.members rec on rec.memid = mem.recommendedby 
    order by 
     surname, 
     firstname;


### Produce a list of all members, along with their recommender, using no joins. (output a list of all members, including the individual who recommended them (if any), without using any joins? with no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.)

    SELECT 
		DISTINCT mem.firstname || ' ' || mem.surname as membername, 
		(
		SELECT 
			rec.firstname || ' ' || rec.surname as recommendername 
		from 
			cd.members rec 
		where 
			rec.memid = mem.recommendedby
		) 
	FROM 
		cd.members mem 
	ORDER BY 
		membername;
		
## Aggregation

### Count the number of recommendations each member makes.  (Produce a count of the number of recommendations each member has made. Order by member ID.)

    SELECT recommendedby, count(*)
        FROM members
        WHERE recommendedby is not null
        group by recommendedby
    ORDER BY recommendedby;


### Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
	SELECT 
		facid, 
	SUM(slots) as "Total Slots" 
	FROM 
		cd.bookings 
	group by 
		facid 
	order by 
		facid;


### List the total slots booked per facility in a given month (Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.)
    
	SELECT 
		facid, 
		SUM(slots) as "Total Slots" 
	FROM 
		cd.bookings 
	where 
		starttime between '2012-09-01' 
		AND '2012-10-01' 
	GROUP BY 
		facid 
	ORDER BY 
		"Total Slots";


### List the total slots booked per facility per month (Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.)
	SELECT 
		facid, 
	EXTRACT(
		month 
    from 
		starttime
	
	) 	as month, 
		Sum(slots) as "Total Slots" 
	from 
		cd.bookings 
	where 
		EXTRACT(
		year 
		from 
		starttime
	)= 2012 
	group by 
		facid, 
		month 
	order by 
		facid, 
		month;



###Find the count of members who have made at least one booking ( Find the total number of members (including guests) who have made at least one booking.)

	SELECT 
		COUNT(DISTINCT memid) 
	FROM 
		cd.bookings;


### List each member''s first booking after September 1st 2012 (Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.)

	SELECT 
		mem.surname, 
		mem.firstname, 
		mem.memid, 
		min(bkg.starttime) as starttime 
	FROM 
		cd.bookings bkg 
		inner join cd.members mem on mem.memid = bkg.memid 
	WHERE 
		starttime > '2012-09-01' 
	GROUP BY 
		mem.surname, 
		mem.firstname, 
		mem.memid 
	ORDER BY 
		mem.memid;


### list of member names, with each row containing the total member count (Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.)


	SELECT 
		COUNT(*) over(), 
		firstname, 
		surname 
	FROM 
		cd.members 
	ORDER BY 
		joindate


### Produce a numbered list of members (Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.)

	SELECT 
		row_number() OVER(
			ORDER BY 
				joindate
	), 
		firstname, 
		surname 
	from 
		cd.members;


### Output the facility id that has the highest number of slots booked, again (Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.)
	select 
	  facid, 
      total 
	from 
	 (
		select 
		  facid, 
          sum(slots) total, 
          rank() over (
            order by 
               sum(slots) desc
      ) rank 
	FROM 
      cd.bookings 
    group by 
      facid
  ) as ranked 
where 
  rank = 1




## String

### Format the names of members (Output the names of all members, formatted as 'Surname, Firstname')

	SELECT 
		surname || ', ' || firstname as name 
	FROM 
		cd.members;


### Find telephone numbers with parentheses (You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You''d like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.)

	SELECT 
		memid, 
		telephone 
	FROM 
		cd.members 
	WHERE 
		telephone like '%(%' 
		OR telephone like '%)%';



### Count the number of members whose surname starts with each letter of the alphabet (You''d like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don''t worry about printing out a letter if the count is 0.)

	SELECT 
		substr (mems.surname, 1, 1) as letter, 
		count(*) as count 
	FROM 
		cd.members mems 
	GROUP BY 
		letter 
	ORDER BY 
		letter;


