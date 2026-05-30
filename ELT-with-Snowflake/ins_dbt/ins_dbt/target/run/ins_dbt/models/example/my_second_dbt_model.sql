
  create or replace   view INSURANCE.ANALYTICS.my_second_dbt_model
  
  
  
  
  as (
    -- Use the `ref` function to select from other models

select *
from INSURANCE.ANALYTICS.my_first_dbt_model
where id = 1
  );

