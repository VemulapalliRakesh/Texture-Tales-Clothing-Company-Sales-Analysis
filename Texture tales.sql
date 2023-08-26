create database CS4;
USE CS4;

/* What was the total quantity sold for all products?*/
select pd.product_name,sum(s.qty) as "total quantity sold" from product_details pd
join sales s 
on pd.product_id=s.prod_id
group by s.prod_id
order by sum(s.qty) desc;           

/*What is the total generated revenue for all products before discounts?*/
select sum(qty*price) revenue from sales;

/*What was the total discount amount for all products?*/
select sum(qty*price*discount)/100 as discount_amount from sales;

/*How many unique transactions were there?*/
SELECT COUNT(DISTINCT txn_id) 'unique transactions'
FROM sales;

/*What are the average unique products purchased in each transaction?*/
With cte_transaction_products as 
(select count(distinct prod_id)as count,txn_id from sales 
group by txn_id)

select round(avg(count)) as "unique products" from cte_transaction_products;

/*What is the average discount value per transaction?*/
with cte as 
(select sum(qty*price*discount)/100 as total_discount from sales 
group by txn_id)
select round(avg(total_discount)) as average_discount from cte;

/*What is the average revenue for member transactions and non-member transactions?*/
# Average revenue for member transactions
WITH cte_member_revenue AS (
  SELECT
    member,
    txn_id,
    SUM(price * qty) AS revenue
  FROM sales
  GROUP BY 
	member, 
	txn_id
)
SELECT
  member,
  ROUND(AVG(revenue), 2) AS avg_revenue
FROM cte_member_revenue
GROUP BY member;


/*What are the top 3 products by total revenue before discount?*/
with cte as
(select pd.product_name,sum(s.qty*s.price) as revenue,row_number() over(order by sum(s.qty*s.price)desc) as rn
from product_details pd
join 
sales s
on s.prod_id=pd.product_id
group by pd.product_id
)

select product_name,revenue from cte where rn<=3;

/*What are the total quantity, revenue and discount for each segment?*/
select segment_name, sum(qty) "total quantity",sum(qty*s.price) revenue,sum(qty*s.price*discount)/100 discount
from product_details pd 
join 
sales s
on pd.product_id=s.prod_id 
group by segment_name
order by revenue desc;

/*What is the top selling product for each segment*/
with cte as 
(select pd.product_name,sum(qty*s.price) as Revenue,segment_name,rank() over(partition by segment_name order by sum(qty*s.price) desc) as rn
from sales s
inner join 
product_details pd
on s.prod_id=pd.product_id
group by segment_name)

select product_name,segment_name from cte where rn=1;


/*What are the total quantity, revenue and discount for each category?*/
select category_name, sum(qty) "total quantity",sum(qty*s.price) revenue,sum(qty*s.price*discount)/100 discount
from product_details pd 
join 
sales s
on pd.product_id=s.prod_id 
group by category_name
order by revenue desc;

/*What is the top selling product for each category?*/
with cte as 
(select pd.product_name,sum(qty) as Revenue,category_name,rank() over(partition by category_name order by sum(qty*s.price) desc) as rn
from sales s
inner join 
product_details pd
on s.prod_id=pd.product_id
group by category_id)

select product_name,category_name from cte where rn=1;

