-- customer====	     id,firstname, lastname, joindate, country
-- giftcard====  	 id, amountworth, customerid, paymentdate, paymentamount
-- movie====    	 id, title, releaseyear, genre, editorrating
-- review====    	 id, rating, customerid, movieid
-- single_rental==== id, rentaldate, rentalperiod, platform, customerid, movieid, paymentdate, paymentamount
-- subscription====  id, length, startdate, platform, paymentdate, paymentamount, customerid

#altering id in tables:
#ALTER TABLE movie RENAME COLUMN ï»¿id TO id;
#ALTER TABLE review RENAME COLUMN ï»¿id TO id;
#ALTER TABLE customer RENAME COLUMN ï»¿id TO id;
#ALTER TABLE single_rental RENAME COLUMN ï»¿id TO id;
#ALTER TABLE giftcard RENAME COLUMN ï»¿id TO id;
#ALTER TABLE subscription RENAME COLUMN ï»¿id TO id;
-- #-----------SQL Assigment-7---------------

-- Q1.For each distinctive movie, show the title, the average customer rating for that movie, 
-- the average customer rating for the entire genre and the average customer rating for all movies.

select distinct m.title, 
	   avg(r.rating) over(partition by m.title) avg_rating_by_movie, 
	   avg(r.rating) over(partition by genre) avg_rating_by_genre,
       avg(r.rating) over() ttl_avg_rating
from movie m join review r on m.id= r.movie_id
order by m.title
;

with subquery as(
	select m.title, 
		avg(r.rating) over() as avg1,
		avg(r.rating) over(partition by movie_id) as avg2,
		avg(r.rating) over(partition by genre) as avg3
	from movie m, review r
	where m.id = r.movie_id
	)
select title, avg(avg1), avg(avg2), avg(avg3) from subquery group by title
order by title
;


-- Q2.For each customer, show the following information: first_name, last_name, 
-- the average payment_amount from single rentals by that customer and 
-- the average payment_amount from single rentals by any customer from the same country.
select distinct c.id,c.first_name, c.last_name,
	   round(avg(s.payment_amount) over(partition by c.id),2) avg_amt_by_customer, 
	   round(avg(s.payment_amount) over(partition by country),2) avg_amt_by_country
from customer c join single_rental s on c.id= s.customer_id 
order by c.first_name, c.country
;


-- Q3.Show the first and last name of the customer who bought the second most 
-- recent giftcard along with the date when the payment took place.
--  Assume that an individual rank is assigned for each giftcard purchase.
- "assuming user purchased the giftcard on the day they joined "to find second most recent" ";

with cte as
(select c.first_name, 
	   c.last_name,
       g.payment_date,
	   dense_rank() over(order by join_date desc) recent_gftcrd_rnk
from customer c join giftcard g on c.id = g.customer_id
)
select * from cte where recent_gftcrd_rnk=2
;

--  Assume that an individual rank is assigned for each giftcard purchase. WHY THIS??
with cte as
(select *, dense_rank() over(order by ttl desc) rnk_by_gftccrd_purchase_cnt
from
(select c.id,c.first_name, c.last_name, g.payment_date, count(amount_worth) ttl
from customer c left join giftcard g on c.id = g.customer_id
group by c.id) t
)
select * from cte where rnk_by_gftccrd_purchase_cnt=2
;


with ranking as(
    select c.first_name, c.last_name, g.payment_date,
        row_number() over(order by g.payment_date desc) as rank1
    from customer c, giftcard g
    where c.id = g.customer_id
    )
select first_name, last_name, payment_date from ranking where rank1=2
;

-- Q4.For each single rental, show the rental_date, the title of the movie rented, its genre, 
-- the payment_amount and the rank of the rental in terms of the price paid (the most expensive rental should have rank = 1). 
-- The ranking should be created separately for each movie genre. 
-- Allow the same rank for multiple rows and allow gaps in numbering too.

select s.rental_date, m.title, m.genre, s.payment_amount, rank() over(partition by m.genre order by s.payment_amount desc) rnk
from single_rental s join movie m on s.movie_id=m.id
order by rnk, m.genre
;

-- Q5.For each single rental, show the id, rental_date, payment_amount and the running total of payment_amounts 
-- of all rentals from the oldest one (in terms of rental_date) until the current row.
-- SELECT id, rental_date, payment_amount
select id, rental_date, payment_amount, 
	   sum(payment_amount)over(order by rental_date rows between unbounded preceding and current row) running_ttl
from single_rental 
;


-- Q6.For each subscription, show the following columns: id, length, platform, payment_date,
--  payment_amount and the future cashflows calculated as the total money from all 
--  subscriptions starting from the beginning of the payment_date of the current row 
-- (i.e. include any other payments on the very same date) until the very end.
select id,
	   length,
	   platform, 
       payment_date, 
       start_date, 
       payment_amount,
	   payment_amount*(length - datediff(STR_TO_DATE(payment_date,'%d-%m-%Y'), STR_TO_DATE(start_date,'%d-%m-%Y')) -1) as future_cashflows
from subscription
;


-- Q7.For each single rental, show the following information: rental_date, title of the movie rented, 
-- genre of the movie, payment_amount and the highest payment_amount for any movie in the same 
-- genre rented from the first day up to the current rental_date.

select s.rental_date,
	   s.id,
	   m.title, 
       m.genre, 
       s.payment_amount,
	   max(payment_amount) over(partition by m.genre order by s.rental_date rows between unbounded preceding and current row) higest_payment_amt
from single_rental s join movie m on s.movie_id= m.id
;

-- Q8.For each giftcard, show its amount_worth, payment_amount and two more columns: 
-- the payment_amount of the first and last giftcards purchased in terms of the payment_date.
with cte as
(select customer_id,
	   amount_worth, 
	   payment_amount,
       payment_date,
	   rank() over(partition by customer_id order by (STR_TO_DATE(payment_date,'%d-%m-%Y')) desc ) first_crd,
       rank() over(partition by customer_id order by (STR_TO_DATE(payment_date,'%d-%m-%Y')) desc) lst_crd
from giftcard
)
select  customer_id,
		amount_worth, 
		payment_amount,
	    case when first_crd= count(customer_id) then payment_amount   end as first_giftcard,
        case when lst_crd= 1 then payment_amount   end as last_giftcard
from cte
group by customer_id
;

SELECT amount_worth, payment_amount,
  	FIRST_VALUE(payment_amount) OVER(ORDER BY payment_date),
    LAST_VALUE(payment_amount) OVER(ORDER BY payment_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM giftcard;


-- Q9.For each rental date, show the rental_date, the sum of payment amounts (column name payment_amounts)
--  from single_rentals on that day, the sum of payment_amounts on the previous day and 
--  the difference between these two values.

select *, abs(ttl-previous_day_ttl) as diff
from
(select *,  ifnull(lag(ttl,1) over(),0) as previous_day_ttl
from
(select rental_date, sum(payment_amount) ttl 
from single_rental
group by rental_date
)t
)tt
;


-- Q10.For each customer, show the following information: first_name, last_name, 
--  the sum of payments (AS sum_of_payments) for all single rentals and the sum of payments of 
--  the median customer in terms of the sum of payments 
--  (since there are 7 customers, pick the 4th customer as the median).

select *, case when rno= 4 then payment_amount end as median_cust 
from
(select c.first_name, c.last_name, payment_amount, sum(payment_amount) over() as sum_of_payments, row_number() over() as rno
from customer c left join single_rental s on s.customer_id=c.id
group by customer_id
)t
;

WITH subquery AS(
    SELECT first_name, last_name, SUM(payment_amount) AS sum_of_payments
    FROM single_rental s, customer c
    WHERE c.id = s.customer_id
    GROUP BY first_name, last_name
  	ORDER BY sum_of_payments
  )
SELECT first_name, last_name, sum_of_payments,
	NTH_VALUE(sum_of_payments, 4) OVER()
FROM subquery;

