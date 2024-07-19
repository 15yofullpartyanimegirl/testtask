-- 1
-- cast EXPIRE_DT to timestamp
CALL public.fill_bucket();
CALL public.fill_bucket();

-- 2
CALL fill_flag('ADDR_FACT_FLG', 'POST_FACT');
-- call, call

-- 3
-- "идентификаторы заемщика, договора, стартовый долг amount"

-- 4
ALTER TABLE ex1 ADD "AGE" int4;
update ex1 set "BIRTH_DT"=null where "BIRTH_DT"='';
-- cast BIRTH_DT to timestamp
-- update ex1 set "BIRTH_DT"=null where "BIRTH_DT"='';
-- ALTER TABLE public.ex1 ALTER COLUMN "BIRTH_DT" TYPE timestamp USING "BIRTH_DT"::timestamp;
CALL fill_age('01.06.2018 0:00:00');

-- 5
CALL fill_wrk();
-- trunc datetime to days inside proc as option
-- update ex1 set "WORK_START_DT"=null where "WORK_START_DT"='';
-- ALTER TABLE public.ex1 ALTER COLUMN "WORK_START_DT" TYPE timestamp USING "WORK_START_DT"::timestamp;
-- update ex1 set "WORK_START_DT"=date_trunc('day', "WORK_START_DT");

-- 6
-- in fill_exp() fileds

-- 7
CALL fill_exp();