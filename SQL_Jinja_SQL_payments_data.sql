-- Take the list of payment_methods from the stg_stripe__payments model
-- use this to create a list in Jinja 
-- and then loop through the list to generate a SQL query that pivots the rows to columns for each payment_method

-- CTE to connect to the stg_stripe__payments model
with

payments as(

select * from {{ ref('stg_stripe__payments') }}

)

-- SQL Query Start
select 

    payment_id,

-- sub-query in Jinja used to get the values of the payment_methods from the table itself (instead of manually typing them out)
-- then insert the values into a list object
    {%- set payment_method -%}
        SELECT DISTINCT paymentmethod
        FROM {{ ref('stg_stripe__payments') }}
    {%- endset -%}

    {%- set rows = run_query(payment_method) -%}

    {%- if execute -%}
    {%- set column_headers = rows.columns[0].values() -%}
    {%- else -%}
    {%- set column_headers = [] -%}
    {%- endif -%}

-- For loop to run through each value in the list, in order to pivot the payment_method from rows to columns

    {% for header in column_headers %}

    sum(case when paymentmethod = '{{ header }}' then payment_amount ELSE 0 END) as {{ header }}_amount

        {%- if not loop.last -%}
            ,
        {%- endif -%}

    {% endfor %}

from payments
GROUP BY 1

-- SQL Query End
