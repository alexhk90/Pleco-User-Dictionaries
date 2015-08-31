-- Create new table (combined) with relevant columns for Pleco user dictionary.

create table combined as
select definitions.id, definitions.idx, entries.title, heteronyms.pinyin,
definitions.type, definitions.def, definitions.example, definitions.quote,
definitions.synonyms, definitions.antonyms, definitions.link
from definitions, heteronyms, entries
where definitions.heteronym_id = heteronyms.id and heteronyms.entry_id = entries.id;

-- Combine definition fields into single field.

-- Process (Western) comma separators (replace with Pleco new line or Chinese list separators):
update combined set example = replace(example, ',', '');
update combined set quote = replace(quote, ',', '');
update combined set synonyms = replace(synonyms, ',', '、');
update combined set antonyms = replace(antonyms, ',', '、');
update combined set link = replace(link, ',', '');

/* Replace null entries to empty strings '' for combining/counting later
(otherwise can causes problems with null results,
especially when using type for counting number of definitions),
and at same time add label for synonyms and antonyms:*/
update combined set
type = case when coalesce(type, '') = '' then '' else type end;
update combined set
def = case when coalesce(def, '') = '' then '' else def end;
update combined set
example = case when coalesce(example, '') = '' then '' else example end;
update combined set
quote = case when coalesce(quote, '') = '' then '' else quote end;
update combined set
synonyms = case when coalesce(synonyms, '') = '' then '' else '似：'||synonyms end;
update combined set
antonyms = case when coalesce(antonyms, '') = '' then '' else '反：'||antonyms end;
update combined set
link = case when coalesce(link, '') = '' then '' else link end;

-- Now combine into single field newdef:
alter table combined add column newdef;
update combined set newdef = '';
update combined set newdef = case when coalesce(def, '') = ''
then newdef else def end;
update combined set newdef = (case when coalesce(example, '') = ''
then newdef else (case when coalesce(newdef, '') = ''
then example else newdef||''||example end) end);
update combined set newdef = (case when coalesce(quote, '') = ''
then newdef else (case when coalesce(newdef, '') = ''
then quote else newdef||''||quote end) end);
update combined set newdef = (case when coalesce(synonyms, '') = ''
then newdef else (case when coalesce(newdef, '') = ''
then synonyms else newdef||''||synonyms end) end);
update combined set newdef = (case when coalesce(antonyms, '') = ''
then newdef else (case when coalesce(newdef, '') = ''
then antonyms else newdef||''||antonyms end) end);
update combined set newdef = (case when coalesce(link, '') = ''
then newdef else (case when coalesce(newdef, '') = ''
then link else newdef||''||link end) end);

/* Add numbering to combined definitions:
order by idx then count up to current id.*/

create table combined2 as
select id, title, pinyin, idx, type, newdef,
(select count(*) from combined c2 where c1.title=c2.title and c1.pinyin=c2.pinyin and c1.type=c2.type and c2.id<=c1.id) as defid,
(select count(*) from combined c2 where c1.title=c2.title and c1.pinyin=c2.pinyin and c1.type=c2.type) as defcount
from combined c1;

-- Add numbering (only if more than one definition in unique title, pinyin, type):
update combined2 set newdef =
(case when defcount<=1 then newdef
else '(@'||defid||'@) '||newdef end);

-- Replace with circled numbers:
update combined2 set newdef = replace(newdef, '(@1@)','①');
update combined2 set newdef = replace(newdef, '(@2@)','②');
update combined2 set newdef = replace(newdef, '(@3@)','③');
update combined2 set newdef = replace(newdef, '(@4@)','④');
update combined2 set newdef = replace(newdef, '(@5@)','⑤');
update combined2 set newdef = replace(newdef, '(@6@)','⑥');
update combined2 set newdef = replace(newdef, '(@7@)','⑦');
update combined2 set newdef = replace(newdef, '(@8@)','⑧');
update combined2 set newdef = replace(newdef, '(@9@)','⑨');
update combined2 set newdef = replace(newdef, '(@10@)','⑩');
update combined2 set newdef = replace(newdef, '(@11@)','⑪');
update combined2 set newdef = replace(newdef, '(@12@)','⑫');
update combined2 set newdef = replace(newdef, '(@13@)','⑬');
update combined2 set newdef = replace(newdef, '(@14@)','⑭');
update combined2 set newdef = replace(newdef, '(@15@)','⑮');
update combined2 set newdef = replace(newdef, '(@16@)','⑯');
update combined2 set newdef = replace(newdef, '(@17@)','⑰');
update combined2 set newdef = replace(newdef, '(@18@)','⑱');
update combined2 set newdef = replace(newdef, '(@19@)','⑲');
update combined2 set newdef = replace(newdef, '(@20@)','⑳');
-- Note: max(defcount) suggests only need to go up to 19.

-- Group by part of speech (title, pinyin, type):
create table combined3 as
select title, pinyin, idx, type, defcount,
group_concat(newdef, '') as newdef3
from (select title, pinyin, idx, type, defcount, newdef
from combined2
order by title, pinyin, defid)
group by title, pinyin, type;

-- Add part of speech (type) count (for determining use of bullet characters):
create table combined3a as
select title, pinyin, idx, type, defcount, newdef3,
(select count(*) from combined3 c2 where c1.title=c2.title and c1.pinyin=c2.pinyin) as partcount
from combined3 c1;

-- Add bullet character if more than one part of speech (type):
alter table combined3a add column bullet;
update combined3a set bullet =
(case when partcount>1
then '◆ '
else '' end);

-- Add part of speech (type), bullets and new lines as appropriate:
update combined3a set newdef3 =
(case when coalesce(type, '') = ''
then bullet||newdef3 else
(case when defcount>1
then bullet||'<'||type||'> '||newdef3
else bullet||'<'||type||'> '||newdef3 end) end);

-- Group by Hanzi/Pinyin (title, pinyin):
create table combined4 as
select title, pinyin, group_concat(newdef3, '') as newdef4
from (select title, pinyin, idx, type, newdef3
from combined3a
order by title, pinyin, idx)
group by title, pinyin;

-- Replace Chinese brackets with Western brackets in pinyin field (to show in Pleco):
update combined4 set pinyin=
replace(pinyin, '（', ' (');
update combined4 set pinyin=
replace(pinyin, '）', ') ');

-- Move bracketed Western names from title (Hanzi) field to start of definition field:
update combined4 set
newdef4=substr(title,instr(title,'('))||' '||newdef4,
title=substr(title,1,instr(title,'(')-1)
where title like '%)';

-- Output counts for consistency checking:
select count(*) from combined2; -- (unique title, pinyin, type, def) = 213486;
select count(*) from combined3; -- (unique title, pinyin, type) = 171378;
select count(*) from combined4; -- (unique title, pinyin) = 165810.