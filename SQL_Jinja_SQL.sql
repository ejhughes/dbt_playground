-- Testing how to use a SQL query to generate a list in Jinja that can then be used in a for loop to iterate through in a SQL query.

-- Generate initial SQL query (a simple column of numbers) & set this as a Jinja variable
-- Usually this would look more like:
-- set:
-- SELECT DISTINCT [field]
-- FROM [table]

{% set my_list %}
    SELECT DISTINCT num
    FROM (
        SELECT 10 as num
        UNION
        SELECT 11
        UNION 
        SELECT 12
        ) num_table
    ORDER BY num
{% endset %}

-- Use the run_query macro to run the query within the previous block and generate a table object

{% set rows = run_query(my_list) %}

-- Use if execute to ensure that myOrders (which relies on the SQL query to be run) is only set at the execution state, after compilation
-- (Normaly Jinja will run at compilation phase in order to operate source and ref functions used to determine lineage for the DAG

{% if execute %}
{# Return the first column #}
{% set myOrders = rows.columns[0].values() %}
{% else %}
{% set myOrders = [] %}
{% endif %}

-- loop through the items in the myOrders list and run these through a SQL query
  
{% for num in myOrders %}

    SELECT {{ num }}

    {% if not loop.last %}

    UNION

    {% endif %}

{% endfor %}
