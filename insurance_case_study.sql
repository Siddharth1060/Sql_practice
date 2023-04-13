select * from insurance;

-- Retrieve the top 3 patients with the highest claim amount, along with their 
-- -- respective claim amounts and the total claim amount for all patients.
-- Select the PatientID, age, and BMI for patients with a BMI between 40 and 50.
select patientid, age, bmi
from insurance
where bmi between 40 and 50;

-- Select the maximum and minimum BMI values in the table.
select max(bmi), min(bmi)
from insurance;
-- Select the number of smokers in each region.
select count(patientid) 
from insurance 
where smoker='Yes'
group by region
having count(PatientID)> 60;

-- -----------------------------------------------------
-- #-----------SQL Assigment-3---------------

-- 1. Select all columns for all patients.
select * from insurance;

-- 2. Display the average claim amount for patients in each region.
select region, avg(claim)
from insurance
group by region;

-- 3. Select the maximum and minimum BMI values in the table.
select max(bmi), min(bmi) -- as seperate columns
from insurance;
-- -- -- -- --
(select bmi from insurance order by bmi limit 1) -- as same column, seperate rows
union all
(select bmi from insurance order by bmi desc limit 1);

-- 4. Select the PatientID, age, and BMI for patients with a BMI between 40 and 50.
select patientid, age, bmi
from insurance
where bmi between 40 and 50;

-- 5. Select the number of smokers in each region.
select region, count(smoker)
from insurance
where smoker= 'Yes'
group by region;

-- 6. What is the average claim amount for patients who are both diabetic and smokers?
select avg(claim)
from insurance
where diabetic= 'Yes' and smoker= 'Yes';

-- 7. Retrieve all patients who have a BMI greater 
--        than the average BMI of patients who are smokers.
select bmi
from insurance
where bmi > (select avg(bmi) from insurance where smoker='Yes');

-- 8. Select the average claim amount for patients in each age group.
select age, round(avg(claim),2)
from insurance
group by age
order by age;

-- 9. Retrieve the total claim amount for each patient, along with the average claim amount across all patients.
select patientid, sum(claim), (select round(avg(claim),2) from insurance)
from insurance
group by patientid;

-- 10. Retrieve the top 3 patients with the highest claim amount, along with their 
-- respective claim amounts and the total claim amount for all patients.
select patientid, claim, (select round(sum(claim),2) from insurance) as ttl_claim
from 
insurance
order by claim desc
limit 3;

-- 11. Select the details of patients who have a claim amount 
-- greater than the average claim amount for their region.
select *
from 
(select *, avg(claim) over(partition by region) as avg_claim
from insurance)t
where claim > avg_claim;

-- 12. Retrieve the rank of each patient based on their claim amount.
select patientid, claim, dense_rank() over(order by claim desc) as rnk
from insurance;

-- 13. Select the details of patients along with their claim amount, 
-- and their rank based on claim amount within their region.

select *, rank() over(partition by region order by claim desc) as rnk
 from insurance;
