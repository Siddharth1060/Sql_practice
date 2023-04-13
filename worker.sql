-- CREATE TABLE Worker (
-- 	WORKER_ID INT NOT NULL PRIMARY KEY,
-- 	FIRST_NAME CHAR(25),
-- 	LAST_NAME CHAR(25),
-- 	SALARY INT(15),
-- 	JOINING_DATE DATETIME,
-- 	DEPARTMENT CHAR(25)
-- );

-- INSERT INTO Worker 
-- 	(WORKER_ID, FIRST_NAME, LAST_NAME, SALARY, JOINING_DATE, DEPARTMENT) VALUES
-- 		(1, 'Monika', 'Arora', 100000, '14-02-20 09.00.00', 'HR'),
-- 		(2, 'Niharika', 'Verma', 80000, '14-06-11 09.00.00', 'Admin'),
-- 		(3, 'Vishal', 'Singhal', 300000, '14-02-20 09.00.00', 'HR'),
-- 		(4, 'Amitabh', 'Singh', 500000, '14-02-20 09.00.00', 'Admin'),
-- 		(5, 'Vivek', 'Bhati', 500000, '14-06-11 09.00.00', 'Admin'),
-- 		(6, 'Vipul', 'Diwan', 200000, '14-06-11 09.00.00', 'Account'),
-- 		(7, 'Satish', 'Kumar', 75000, '14-01-20 09.00.00', 'Account'),
-- 		(8, 'Geetika', 'Chauhan', 90000, '14-04-11 09.00.00', 'Admin');
--         
-- Q1. WAQ to get the details of the worker where the length of the first name greater than or equal to 8.
select first_name
from worker
where length(first_name)>=8 ;

-- Q2. WAQ to append '@example.com' to first_name field.
update worker
set first_name= '@example.com'
where worker_id=1;

select first_name
from worker
where worker_id=1;

-- Q3. WAQ to find all work where last names are in upper case.
select *
from worker
where department= binary upper(department);

-- Q4. WAQ to find all work with firstname and lastname together.
select concat(first_name, " ",last_name) as full_name
from worker;


-- Q5. WAQ to extract the first 2 character of DEPARTMENT.
select left(department,2)
from worker;

-- Q6. WAQ to get the last name of work in rever order and in upper case.
select reverse(upper(last_name))
from worker;



-- Q7. WAQ to display the first name contain "it" .
select *
from worker
where  first_name like "%it%" ;

-- Q8. WAQ to get the date from joining date.
select date(joining_date) as dt
from worker;

-- Q9. WAQ to get first name,last name,joining date with salary seperated by "--" and fisrt and last name in upper case.
select concat(upper(first_name),' -- ',upper(last_name),' -- ',joining_date,' -- ',salary)
from worker;
-- Q10.WAQ to get lenth of department and Last name and display both seperated by "-".
select concat(length(department),' - ',length(last_name)) as 'department-last_name'
from worker;

-- ------------------------------------------------------ --

#-----------SQL Assigment-2---------------

-- Q1. write query to find duplicate rows.
select *, count(*)
from worker
group by worker_id
having count(*)>=1;


-- Q2. Write an SQL query to show only even rows from a table using subquery .
select * 
from (select *, row_number() over() as rn
		from worker
		)t
where rn%2=0;

-- Q3. Find employees in worker table that do not exist in bonus table (ie did not get bonus).
select concat(first_name,' ', last_name)
from worker -- w left join bonus b on w.worker_id= b.worker_id where b.salary is Null
where worker_id not in (select worker_id 
						from bonus			# assuming there's a bonus table
                        );
-- Q4. Find people who have the same salary.
select w1.worker_id, w1.first_name, w1.last_name,w1.salary, w2.worker_id,w2.first_name, w2.last_name,w2.salary
from worker w1 join worker w2 on w1.worker_id <> w2.worker_id and w1.salary=w2.salary;

-- Q5. Query to show same row twice.
select * from worker
union all
select * from worker
order by worker_id;

-- Q6. Query to fetch 1st 50% records (worker) table.
select *
from
	(select *, ntile(2) over() as bucket 
	from worker)t
where bucket=1;


-- Q7. select 1st and last row of a worker table.
with cte as
(
	 select *, row_number() over() as rn
     from worker
	)
(select * from cte order by rn limit 1)
union all
(select * from cte order by rn desc limit 1);

-- Q8. select last 5 entries of a worker table. 
select *
from worker
order by time(joining_date)
limit 5;

-- Q9. Write an SQL query that fetches the unique values of DEPARTMENT from Worker table and prints its length
select distinct department, length( department), count(department)
from
worker
group by department;

-- Q.10  Show the details workers who are managers.
select *
from worker
where worker_id in (select manager_id from manager) # assuming there's a manager table
