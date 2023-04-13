-- create table sales(
--   customer_id varchar(1),
--   order_date date,
--   product_id int);

--   insert into sales(customer_id, order_date,product_id)
--   values
--  ('A', '2021-01-01', '1'),
--   ('A', '2021-01-01', '2'),
--   ('A', '2021-01-07', '2'),
--   ('A', '2021-01-10', '3'),
--   ('A', '2021-01-11', '3'),
--   ('A', '2021-01-11', '3'),
--   ('B', '2021-01-01', '2'),
--   ('B', '2021-01-02', '2'),
--   ('B', '2021-01-04', '1'),
--   ('B', '2021-01-11', '1'),
--   ('B', '2021-01-16', '3'),
--   ('B', '2021-02-01', '3'),
--   ('C', '2021-01-01', '3'),
--   ('C', '2021-01-01', '3'),
--   ('C', '2021-01-07', '3');
--   create table menu(
--   product_id int,
--   product_name varchar(10),
--   price int);
--   
--   insert into menu(product_id, product_name, price)
--   values
--  ('1', 'sushi', '10'),
--   ('2', 'curry', '15'),
--   ('3', 'ramen', '12');
--   
--   create table members (
--   customer_id VARCHAR(1), 
--   join_date DATE);
--   insert into members(customer_id,join_date)
--   values
--   ('A','2021-01-07'),
--   ('B','2021-01-09');

#-----------SQL Assigment-4---------------
-- sales -- customer_id,order_date, product_id
-- menu -- product_id, product_name, price
-- members -- customer_id, join_date

  #1. What is the total amount each customer spent at the restaurant?
select m.customer_id, sum(mu.price) 
from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
group by m.customer_id;


  #2. How many days has each customer visited the restaurant?
select m.customer_id, count(distinct s.order_date)
from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
group by customer_id;
  
  #3. What was the first item from the menu purchased by each customer?
  
 select *
from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
               ;
select s.customer_id, s.product_id, s.order_date
from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
group by s.customer_id, s.order_date, mu.product_id
order by s.order_date
;

with cte as
(
select s.customer_id, mu.product_name, s.order_date, dense_rank() over(partition by s.customer_id order by order_date) as rnk
from sales s join menu mu on s.product_id= mu.product_id
)
select *
from cte
where rnk=1
group by customer_id, product_name, order_date
; 

  
  #4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select mu.product_id ,  count(order_date)
from sales s join menu mu on s.product_id=mu.product_id
group by product_id;


  #5. Which item was the most popular for each customer?
select *
from sales s join menu mu on s.product_id=mu.product_id;  
  
select *
from
	(select *, rank() over(partition by customer_id order by cnt desc) rnk
	from 
		(select s.customer_id ,mu.product_name, count(s.order_date) cnt
			  from menu mu join sales s on s.product_id= mu.product_id
			  group by s.customer_id, s.product_id
		) t
	)tt
where rnk=1;

with cte as(
select count(s.product_id)as cc,s.product_id,customer_id  from sales s
join menu m 
on s.product_id =m.product_id 
group by s.product_id,customer_id)
select max(cc),customer_id from cte
group by customer_id;

-- how to do with just windows function and no subquery? ('can't order by count(order_date) in window')
-- spent half hour trying to simplify, but couldn't!!!!!!
  
  #6. Which item was purchased first by the customer after they became a member?

with cte as
(
select s.customer_id, s.order_date, m.join_date ,s.product_id, mu.product_name, rank() over(partition by s.customer_id order by order_date) rnk
from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
where order_date> join_date
)
select customer_id, product_name from cte where rnk=1;

  #7. Which item was purchased just before the customer became a member?
with cte as
(
select s.customer_id, s.order_date, m.join_date ,s.product_id, mu.product_name, rank() over(partition by s.customer_id order by order_date desc) rnk
from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
where order_date< join_date
)
select customer_id, product_name from cte where rnk=1;

  
  #8. What is the total items and amount spent for each member before they become a member?
select *,count(mu.product_Id), sum(mu.price)
from members m right join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
where s.order_date< m.join_date
group by m.customer_id               
;

  
  #9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier- how many points would each customer have?
  select s.customer_id, sum(case when m.product_name='sushi' then price*20 else price*10 end) as points
  from sales s join menu m on s.product_id=m.product_id
  group by s.customer_id
  ;
  
  
  #10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
  --   not just sushi - how many points do customer A and B have at the end of January?
  select s.customer_id, count(s.order_date) no_of_orders, sum( case when (m.join_date<= s.order_date) and (datediff(s.order_date, m.join_date)<= 7) then price*20
				      when (m.join_date<= s.order_date) and (datediff(s.order_date, m.join_date)> 7) and mu.product_name= 'sushi' then price*20
                      when (m.join_date<= s.order_date) and (datediff(s.order_date, m.join_date)<=7) then price*10
                 end     
                ) as points
  from members m join sales s on m.customer_id= s.customer_id
			   join menu mu on s.product_id= mu.product_id
  group by m.customer_id
  order by points desc
  ;