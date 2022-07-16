-- jsea
select model, 
    count(*) as vehicle_count,
    avg(hwy) as avg_hwy,
    avg(cty) as avg_cty,
from vehicles 
group by model
having model like '%hybrid%'
order by avg_hwy desc
;