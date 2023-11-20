--- Inspecting Data
select * from [dbo].[sales_data_sample]

--- Checking Unique Values
select distinct status from [dbo].[sales_data_sample]
select distinct YEAR_ID from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample]
select distinct COUNTRY from [dbo].[sales_data_sample]
select distinct DEALSIZE from [dbo].[sales_data_sample]
select distinct TERRITORY from [dbo].[sales_data_sample]

select distinct MONTH_ID from [dbo].[sales_data_sample]
where YEAR_ID = 2005

---ANALYSIS
----- Grouping sales by productline
select PRODUCTLINE, SUM(sales) Revenue
from [dbo].[sales_data_sample]
group by PRODUCTLINE
order by 2 desc


select YEAR_ID, SUM(sales) Revenue
from [dbo].[sales_data_sample]
group by YEAR_ID
order by 2 desc


select DEALSIZE, SUM(sales) Revenue
from [dbo].[sales_data_sample]
group by DEALSIZE
order by 2 desc


---- What wasthe best month for sales in a specific year? How much was earned that month?
select MONTH_ID, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [dbo].[sales_data_sample]
where YEAR_ID= 2004  ---- Changing year to see the best month for sales in every year
group by MONTH_ID
order by 2 desc


---- November seems to be the best month, what product do they sell in November?
select MONTH_ID, PRODUCTLINE, SUM(sales) Revenue, COUNT(ORDERNUMBER) Frequency
from [dbo].[sales_data_sample]
where YEAR_ID= 2004 AND MONTH_ID = 11  ---- Changing year to see the best Productline sold in every year
group by MONTH_ID, PRODUCTLINE
order by 3 desc


---- Who is our best customer (this could be asnwered with RFM Analysis)

DROP TABLE IF EXISTS #rfm
;with rfm as
(
	select 
		CUSTOMERNAME,
		SUM(sales) MonetaryValue,
		AVG(sales) AvgMonetaryValue,
		COUNT(ORDERNUMBER) Frequency,
		MAX(ORDERDATE) Last_Order_Date,
		(select MAX(ORDERDATE) from [dbo].[sales_data_sample]) Max_Order_Date,
		DATEDIFF(DD, MAX(ORDERDATE), (select MAX(ORDERDATE) from [dbo].[sales_data_sample])) Recency
	from [dbo].[sales_data_sample]
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		NTILE(4) OVER (order by Recency) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar)+cast(rfm_frequency as varchar)+cast(rfm_monetary as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
	case
		when rfm_cell_string in (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers' --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slippling away, cannot lose' -- (Big spenders who haven't purchased lately) slipping away
		when rfm_cell_string in (311, 411, 311) then 'new customer'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333, 321, 422, 322, 432) then 'active' -- (Customers who buy often & recently, but at low price points)
		when rfm_cell_string in(433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm

-- what products are most often sold together?

select distinct ORDERNUMBER, STUFF(

	(select ',' + PRODUCTCODE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in
		(
			
			select ORDERNUMBER 
			from (
				select ORDERNUMBER, count(*) rn
				FROM [dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path(''))

			,1, 1,'') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc

	