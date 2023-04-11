-- What is the total amount each customer spent on zomato?
SELECT a.user_id,sum(b.price) total_amt_spent from sales a inner join product b on a.product_id=b.product_id group by a.user_id;

select * from users;
select * from product;
select * from sales,product;

-- How many days has each customer visited zomato?
select user_id,count(distinct created_date) distinct_days from sales group by user_id;

USE zomato;
SHOW tables from zomato;

-- What was the first product purchased by each customer?
select *,rank() over(partition by user_id order by created_date) p_rank from sales; -- rank provided to each userid
-- rank provided to each userid

select * from
(select *,rank() over(partition by user_id order by created_date) p_rank from sales) a where p_rank=1;  -- filtering out the first product(ans)

-- What is the most purchased item on the menu and how many times was it bought by all customers?
select product_id,count(product_id) p_count from sales group by product_id order by count(product_id) desc limit 1; -- count of the no of times each product was bought

select product_id from sales group by product_id order by count(product_id) desc limit 1; -- the product bought the most by the customers

select user_id,count(product_id) p_count from sales where product_id = 
(select product_id from sales group by product_id order by count(product_id) desc limit 1)group by user_id; -- most purchased item by a particular customer

-- Which item was the most popular for each customer? or Which is the fav product of most customer?

 select *,rank() over(partition by user_id order by p_count desc) p_rank from
 (select user_id,product_id,count(product_id) p_count from sales group by user_id,product_id)a; 
 
 
select * from (select *,rank() over(partition by user_id order by p_count desc) p_rank from
 (select user_id,product_id,count(product_id) p_count from sales group by user_id,product_id)a)b
 where p_rank =1;  -- answer
 
 -- Which item was purchased first after they became a member?
 
 select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b on a.user_id=b.user_id; -- details of gold users
 
  select * from 
  (select c.*,rank() over (partition by user_id order by created_date) rnk from
  (select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b 
  on a.user_id=b.user_id and created_date>=gold_signup_date) c)d where rnk=1; -- answer
  
  -- which item was purchased just before the customer became a gold member?
    select * from 
  (select c.*,rank() over (partition by user_id order by created_date desc) rnk from
  (select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b 
  on a.user_id=b.user_id and created_date <= gold_signup_date) c)d where rnk=1;
  
  -- what is the total orders and amount spent for each member before they became a member?
  select user_id,count(created_date) order_purchased,sum(price) total_amt_spent from 
  (select c.*,d.price from 
  (select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b 
  on a.user_id=b.user_id and created_date <= gold_signup_date) c inner join product d on c.product_id=d.product_id)e
  group by user_id;
  
  /* if buying each product generates points for eg 5rs=2 zomato point and each 
  product has different purchasing points for eg for p1 5rs=1 zomato point,
  for p2 10rs=5zomato point and p3 5rs=1 zomato point */
  
   -- Calculate the points collected by each customers and for which product most points have been given till now
   select a.*,b.price from sales a inner join product b on a.product_id=b.product_id;
   
  select c.user_id,c.product_id,sum(c.price) from
  (select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
  group by user_id,product_id;
  
select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(c.price) amount from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id) d;

select e.*,CAST(amount/points AS unsigned) as total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(c.price) amount from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id) d)e;

select user_id,sum(total_points) users_total_points from
(select e.*,CAST(amount/points AS unsigned) as total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(c.price) amount from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id) d)e) f group by user_id order by user_id asc;


select user_id,sum(total_points)*2.5 total_money_earned from
(select e.*,CAST(amount/points AS unsigned) as total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(c.price) amount from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id) d)e) f group by user_id order by user_id asc;  -- answer to the first part of the question

select f.* , rank() over(order by total_points_earned desc) rnk from
(select product_id,sum(total_points) total_points_earned from
(select e.*,CAST(amount/points AS unsigned) as total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(c.price) amount from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id) d)e) f group by product_id)f; 


select * from 
(select f.* , rank() over(order by total_points_earned desc) rnk from
(select product_id,sum(total_points) total_points_earned from
(select e.*,CAST(amount/points AS unsigned) as total_points from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(c.price) amount from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id) d)e) f group by product_id)f)g where rnk = 1;  -- to get only one rank
  
  
/* 
Q10. In the first one year after a customer joins the gold program (including their join date) irrespective of what the customer has purchased they earn 
5 zomato points for every 10rs spent who earned more 1/3 and what was their first year?
*/
		/* 
		1 zp= 2rs
		0.5 zp=1rs
		*/

select c.*,d.price*0.5 total_points_earned from
(select 
a.user_id,a.created_date,a.product_id,b.gold_signup_date 
FROM
sales a inner join
goldusers_signup b on a.user_id=b.user_id and created_date>=gold_signup_date and created_date<= DATE_ADD(b.gold_signup_date,INTERVAL 1 year))c
inner join product d on c.product_id=d.product_id;


-- Rank all the transaction of the customers

select *, rank() over(partition by user_id order by created_date) transaction_rank from sales;

-- Rank all the transactions for each member whenever they are a zomato gold member for every non gold member transaction mark as na
select c.*,case when gold_signup_date is null then 'na' else rank() over(partition by user_id order by created_date desc) end as 
rnk from
(select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a left join 
goldusers_signup b on a.user_id=b.user_id and created_date>=gold_signup_date)c;