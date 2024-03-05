use mavenfuzzyfactory;

-- Q1 - Viết các truy vấn để cho thấy sự tăng trưởng về mặt số lượng trong website và đưa ra nhận xét
SELECT
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
    count(distinct website_sessions.website_session_id) as sessions,
	count(distinct orders.order_id) as orders
    
FROM website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id

group by 1,2;

/*
Nhan xet: số lượng session và order mang tính chất mùa vụ tăng dần theo các quý hàng năm,
quý 1 sẽ có số session và order thấp nhất tăng dần đến quý 4.
*/

-- Q2 - Viết các truy vấn để thể hiện hiện được hiệu quả hoạt động của công ty và đưa ra nhận xét

SELECT
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
	count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd) / count(distinct orders.order_id) as revenue_per_order,
    sum(orders.price_usd) / count(distinct website_sessions.website_session_id) as revenue_per_session
FROM website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id

group by 1,2;

/*
Nhan xet: các chiến lược marketing dường như đang đạt hiệu quả khi tỉ lệ chuyển đổi, 
doanh thu mỗi order và doanh thu mỗi session tăng đều qua từng năm.
*/

-- Q3 - Viết truy vấn để hiển thị sự phát triển của các đối tượng khác nhau và đưa ra nhận xét
SELECT
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
	count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) as gsearch_nonbrand_orders,
	count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) as bsearch_nonbrand_orders,
	count(distinct case when utm_campaign = 'brand' then orders.order_id else null end) as brand_search_orders,
	count(distinct case when utm_source is null and http_referer is not null then orders.order_id else null end) as organic_type_in_orders,    
	count(distinct case when utm_source is null and http_referer is null then orders.order_id else null end) as direct_type_in_orders
    
FROM website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
group by 1,2;

/*
Nhan xet: số lượng order của gsearch_nonbrand luôn đạt kết quả cao nhất trong tất cả
các năm so với các kênh còn lại. Vì vậy nên tiếp tục đẩy mạnh ngân sách cho kênh gsearch_nonbrand
đồng thời duy trì các kênh còn lại
*/

-- Q4 - Viết truy vấn để hiển thị tỷ lệ chuyển đổi phiên thành đơn đặt hàng cho các đối tượng đã viết ở yêu cầu 3 và đưa ra nhận xét

SELECT
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
	count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) / count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as gsearch_nonbrand_conv_rt,
	count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) / count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as bsearch_nonbrand_conv_rt,
	count(distinct case when utm_campaign = 'brand' then orders.order_id else null end) / count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_search_conv_rt,
	count(distinct case when utm_source is null and http_referer is not null then orders.order_id else null end) / count(distinct case when utm_source is null and http_referer is not null then website_sessions.website_session_id else null end) as organic_search_conv_rt,    
	count(distinct case when utm_source is null and http_referer is null then orders.order_id else null end) / count(distinct case when utm_source is null and http_referer is null then website_sessions.website_session_id else null end) as direct_type_in_conv_rt
    
FROM website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
group by 1,2;


/*
Nhan xet: tỉ lệ chuyển đổi của tất cả các kênh khá tương đồng, nhưng chỉ có gsearch_nonbrand
là đạt số lượng order lớn nhất. Nghĩa là, tất cả các kênh đều đạt hiệu quả nhưng khách hàng lại
thấy gsearch_nonbrand xuất hiện nhiều hơn. Do vậy, nên tăng thêm ngân sách cho các kênh còn lại
để tăng thêm số lượng order
*/
-- Q5 - Viết truy vấn để thể hiện doanh thu và lợi nhuận theo sản phẩm, tổng doanh thu, tổng lợi nhuận của tất cả các sản phẩm

SELECT
	year(created_at) as yr,
    month(created_at) as mth,
    sum(case when product_id = 1 then price_usd else null end) as mrfuzzy_rev,
    sum(case when product_id = 1 then price_usd - cogs_usd else null end) as mrfuzzy_marg,
    sum(case when product_id = 2 then price_usd else null end) as lovebear_rev,
    sum(case when product_id = 2 then price_usd - cogs_usd else null end) as lovebear_marg   , 
    sum(case when product_id = 3 then price_usd else null end) as birthdaybear_rev,
    sum(case when product_id = 3 then price_usd - cogs_usd else null end) as birthdaybear_marg ,   
    sum(case when product_id = 4 then price_usd else null end) as minbear_rev,
    sum(case when product_id = 4 then price_usd - cogs_usd else null end) as minbear_marg,
    sum(price_usd) as total_revenue,
    sum(price_usd - cogs_usd) as total_margin
FROM order_items
	
group by 1,2;

-- Q6 - Viết truy vấn để tìm hiểu tác động của sản phẩm mới và đưa ra nhận xét 

-- Product only
CREATE TEMPORARY TABLE product_pageview_table
SELECT
website_session_id,
website_pageview_id,
created_at
FROM website_pageviews
WHERE pageview_url = '/products'
;
CREATE TEMPORARY TABLE session_w_next_pageview_after_product_id_table
select
	product_pageview_table.created_at,
    product_pageview_table.website_session_id,
	MIN(website_pageviews.website_pageview_id) as min_next_pageview
FROM product_pageview_table
	LEFT JOIN website_pageviews
		ON product_pageview_table.website_session_id = website_pageviews.website_session_id
		AND product_pageview_table.website_pageview_id < website_pageviews.website_pageview_id
GROUP BY 1,2
;

CREATE TEMPORARY TABLE session_w_next_pageview_after_product_url_table
select
session_w_next_pageview_after_product_id_table.created_at,
session_w_next_pageview_after_product_id_table.website_session_id,
pageview_url as next_url
FROM session_w_next_pageview_after_product_id_table
	LEFT JOIN website_pageviews
		ON session_w_next_pageview_after_product_id_table.min_next_pageview = website_pageviews.website_pageview_id
;        

SELECT
	year(product_pageview_table.created_at) as yr,
    month(product_pageview_table.created_at) as mth,
	count(distinct product_pageview_table.website_session_id) as sessions_to_product_page,
    count(case when next_url is not null then product_pageview_table.website_session_id else null end) as click_to_next,
    count(case when next_url is not null then product_pageview_table.website_session_id else null end)/count(distinct product_pageview_table.website_session_id) as clickthrough_rt,
	count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct product_pageview_table.website_session_id) as products_to_order_rt
    
FROM product_pageview_table
	left join orders
		on product_pageview_table.website_session_id = orders.website_session_id
	left join session_w_next_pageview_after_product_url_table
		on session_w_next_pageview_after_product_url_table.website_session_id=product_pageview_table.website_session_id
	group by 1,2;

/*
Nhan xet: Phần đông khách hàng sau khi đến product page cũng đều xem qua ít nhất 1 sản phẩm, chứng tỏ
thiết kế sản phẩm và hình ảnh đang rất tốt . Tuy nhiên tỉ lệ ng mua vẫn còn rất thấp,
chứng tỏ tính chất của các mặt hàng vẫn chưa thu hút người mua cho lắm.
*/
    
-- Q7 - Viết truy vấn thể hiện mức độ hiệu quả của các cặp sản phẩm được bán kèm và đưa ra nhận xét

SELECT
    orders.primary_product_id,
    count(distinct orders.order_id) as orders,
    count(distinct case when order_items.product_id = 1 then orders.order_id else null end) as x_sell_product1,
    count(distinct case when order_items.product_id = 2 then orders.order_id else null end) as x_sell_product2,
    count(distinct case when order_items.product_id = 3 then orders.order_id else null end) as x_sell_product3,
    count(distinct case when order_items.product_id = 4 then orders.order_id else null end) as x_sell_product4,
	count(distinct case when order_items.product_id = 1 then orders.order_id else null end)/count(distinct orders.order_id) as p1_xsell_rt,
    count(distinct case when order_items.product_id = 2 then orders.order_id else null end)/count(distinct orders.order_id) as p2_xsell_rt,
    count(distinct case when order_items.product_id = 3 then orders.order_id else null end)/count(distinct orders.order_id) as p3_xsell_rt,
    count(distinct case when order_items.product_id = 4 then orders.order_id else null end)/count(distinct orders.order_id) as p4_xsell_rt
FROM mavenfuzzyfactory.orders
	LEFT JOIN order_items
		ON orders.order_id = order_items.order_id
		AND order_items.is_primary_item = 0
WHERE orders.created_at > '2014-12-05'
GROUP BY 1;

/*
Nhan xet: đa số các khách hàng sau khi mua 1 sản phảm đều chọn mua sản phẩm id = 4 tiếp theo
 vì vậy nên đẩy mạnh nhập thêm mã hàng 4
*/
