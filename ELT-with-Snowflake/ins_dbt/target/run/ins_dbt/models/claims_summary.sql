
  create or replace   view INSURANCE.analytics.claims_summary
  
  
  
  
  as (
    select
    date_trunc('month', claim_date) as month,
    claim_type,
    count(*) as claims_count,
    sum(amount) as total_amount,
    sum(case when is_fraud then 1 else 0 end) as fraud_count
from INSURANCE.analytics.stg_claims
group by 1,2
order by 1
  );

