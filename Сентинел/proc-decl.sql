-- DROP PROCEDURE public.fill_bucket();

CREATE OR REPLACE PROCEDURE public.fill_bucket()
 LANGUAGE plpgsql
AS $procedure$
DECLARE 
	bucket0 varchar := '';
	bucket_val record;

	bucket_curs CURSOR FOR SELECT "BUCKET", "EXPIRE_DT" FROM "ex1" order by "EXPIRE_DT" asc for update;
BEGIN
	open bucket_curs;
	fetch bucket_curs into bucket_val;
	
	LOOP
		exit when not FOUND;
	
		IF bucket_val."BUCKET" = ''
		THEN 
			-- UPDATE "ex1" SET "BUCKET"=bucket_val."BUCKET" WHERE CURRENT OF bucket_curs;
			UPDATE "ex1" SET "BUCKET"=bucket0 WHERE CURRENT OF bucket_curs;

		END IF; 

	
		raise notice '%', bucket_val."BUCKET";
		bucket0 := bucket_val."BUCKET";
		fetch bucket_curs into bucket_val;
	END LOOP;

	close bucket_curs;
END;
$procedure$
;

-- DROP PROCEDURE public.fill_flag();

CREATE OR REPLACE PROCEDURE public.fill_flag(col_flag varchar, col varchar)
	LANGUAGE plpgsql
AS $procedure$
BEGIN
	-- raise notice '%', col_flag;
	execute format('update ex1 set %1$I=0 where %1$I is null and %2$I='''';', col_flag, col);
	execute format('update ex1 set %1$I=1 where %1$I is null and %2$I<>'''';', col_flag, col);
END;
$procedure$
;

-- DROP PROCEDURE public.fill_age();

CREATE OR REPLACE PROCEDURE public.fill_age(dump_dt timestamp)
	LANGUAGE plpgsql
AS $procedure$
BEGIN
	-- dump_dt := '01.06.2018 0:00:00';
	update ex1 set "AGE"=extract(year from age(dump_dt::date, "BIRTH_DT"::date)) where "BIRTH_DT" is not null;
END;
$procedure$
;

-- DROP PROCEDURE public.fill_exp();

CREATE OR REPLACE PROCEDURE public.fill_exp()
	LANGUAGE plpgsql
AS $procedure$
DECLARE
	exp_dt timestamp := '01.06.2018 0:00:00';
BEGIN
	update ex1 set "EXPIRE_DAYS"=EXTRACT(EPOCH FROM age(exp_dt::date, "EXPIRE_DT"::date)) / (24*60*60) where "EXPIRE_DAYS" is null;
	
END;
$procedure$
;

-- DROP PROCEDURE public.fill_wrk();

CREATE OR REPLACE PROCEDURE public.fill_wrk()
	LANGUAGE plpgsql
AS $procedure$
BEGIN
	update ex1 set "WORK_START_DT"=	substring("WORK_START_DT"::varchar from 0 for 19)::varchar where char_length("WORK_START_DT"::varchar) > 18;
END;
$procedure$
;
