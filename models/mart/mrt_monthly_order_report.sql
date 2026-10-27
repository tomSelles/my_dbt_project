-- Monthly KPIs: unique users, users from Jawa Timur, orders
-- Note: reads sources directly because staging models are temporarily
-- suffixed (_x/_y) after Git exercises; switch to ref() once main is cleaned.

with orders_with_state as (

    select
        date_trunc(date(orders.order_date, 'Europe/Paris'), month) as order_month,
        orders.order_id,
        orders.user_name,
        users.customer_state
    from {{ source('sales_database', 'order') }} as orders
    left join {{ source('sales_database', 'user') }} as users
        on orders.user_name = users.user_name

)

select
    order_month,
    count(distinct user_name) as total_users,
    count(distinct if(customer_state = 'JAWA TIMUR', user_name, null)) as total_users_jawa_timur,
    count(distinct order_id) as total_orders
from orders_with_state
group by order_month