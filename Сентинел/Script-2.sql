-- 1
select (phones.number
	, asset.debtor_id
	, asset.asset_num
	, phones.id
	, count(phones.id)
	, max(actions.created) --last max()
)
from phones
join actions on phones.number = actions.phone_num
join asset on actions.asset_id = asset.id
where phones.BLOCK_FLG = 'Y'
group by phones.id
having count(actions.result = «Должник лично») > 3

-- 2
UPDATE phones
SET BLOCK_FLG=CASE
   WHEN BLOCK_FLG='Y' THEN '11'
   ELSE '23';

