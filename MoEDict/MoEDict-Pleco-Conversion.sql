/* 20150123-MoEDict-Pleco-05
Info: http://www.plecoforums.com/threads/the-moe-dictionary-is-now-open-source.3606/

Data: http://kcwu.csie.org/~kcwu/moedict/
- https://github.com/g0v/moedict-data/
- dict-revised.json: commit ec75f56 on Nov 18, 2014
- convert JSON to SQLite: https://github.com/g0v/moedict-process/
- convert missing characters to Unicode: https://github.com/g0v/moedict-epub/
Source: http://3du.tw/ https://g0v.hackpad.com/3du.tw-ZNwaun62BP4
Official: http://dict.revised.moe.edu.tw/

- Convert JSON to SQLite (using scripts from moedict-process):
sqlite3 dict-revised.sqlite3 < dict-revised.schema
python2 convert_json_to_sqlite.py
Note: This step is only required if JSON but not SQLite database updated at source.

- Now can open with sqlite to check data (counts):
sqlite3 dict-revised.sqlite3
.schema reveals table structure (or just see dict-revised.schema from moedict-process): 
definitions link to heteronyms link to entries (link to dicts but only 1 dict so unnecessary).
Note: Counts (2013 November version): definitions = 213494; heteronyms = 165829; entries = 163093; dicts = 1.
-- Note: Counts (2013 June version): definitions = 213487; heteronyms = 165825; entries = 163097; dicts = 1.

- Convert missing non Big 5 characters to Unicode: 
use moedict-epub / db2unicode.pl and work on output (dict-revised.unicode.sqlite3).
perl db2unicode.pl | sqlite3 dict-revised.unicode.sqlite3
Note: the Perl script does not convert all missing characters.

- Open the resulting file and run this script:
sqlite3 dict-revised.unicode.sqlite3
.read 20150123-MoEDict-Pleco-05.sql

- Export to Pleco flashcard format:
.mode tabs
.output MoEDict-05-cards.txt
SELECT title,pinyin,newdef4 FROM combined4;
*/

-- 0. Create new table (combined) with relevant columns for Pleco user dictionary.

CREATE TABLE combined AS
  SELECT definitions.id, definitions.idx, entries.title, heteronyms.pinyin,
    definitions.type, definitions.def, definitions.example, definitions.quote,
    definitions.synonyms, definitions.antonyms, definitions.link
  FROM definitions, heteronyms, entries
  WHERE definitions.heteronym_id = heteronyms.id AND heteronyms.entry_id = entries.id;

-- 1. Combine definition fields into single field.

-- 1.a. Process bracketed numbers (used for lists within sub-definitions def) as appropriate:
UPDATE combined SET def = REPLACE(def, '(1)', '(1)') WHERE def LIKE '%(1)%(2)%';
UPDATE combined SET def = REPLACE(def, '(2)', '(2)') WHERE def LIKE '%(1)%(2)%';
UPDATE combined SET def = REPLACE(def, '(3)', '(3)') WHERE def LIKE '%(2)%(3)%';
UPDATE combined SET def = REPLACE(def, '(4)', '(4)') WHERE def LIKE '%(3)%(4)%';
UPDATE combined SET def = REPLACE(def, '(5)', '(5)') WHERE def LIKE '%(4)%(5)%';
UPDATE combined SET def = REPLACE(def, '(6)', '(6)') WHERE def LIKE '%(5)%(6)%';
UPDATE combined SET def = REPLACE(def, '(7)', '(7)') WHERE def LIKE '%(6)%(7)%';
UPDATE combined SET def = REPLACE(def, '(8)', '(8)') WHERE def LIKE '%(7)%(8)%';
UPDATE combined SET def = REPLACE(def, '(9)', '(9)') WHERE def LIKE '%(8)%(9)%';
UPDATE combined SET def = REPLACE(def, '(10)', '(10)') WHERE def LIKE '%(9)%(10)%';
/* Note: The 'where' clause is used to ensure continuous numbering.
In 2013 November source data, only up to (8) is actually found, (9) and (10) are superfluous.
Above method not perfect but should handle most cases except for duplicates like '%(1)%(1)%'. */
/* Manually checked for cases not handled by the above: 
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(1)%(1)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(2)%(2)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(3)%(3)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(4)%(4)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(5)%(5)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(6)%(6)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(7)%(7)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(8)%(8)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(9)%(9)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(10)%(10)%';
and only 3 cases found (all 3 being '%(2)%(2)%'):
1. 三關: upstream typo?;
2. 漢: remove newline when used in reference;
3. 短: upstream typo?.*/
-- Manually correct for the exceptional case above where filled circle used in reference:
UPDATE combined SET def = REPLACE(def, '(2) 條', '(2) 條') WHERE title = '漢' AND pinyin = 'hàn';
/* Additional manual checks made for discontinuous numbering:
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(1)%' AND def NOT LIKE '%(1)%(2)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(2)%' AND def NOT LIKE '%(1)%(2)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(3)%' AND def NOT LIKE '%(2)%(3)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(4)%' AND def NOT LIKE '%(3)%(4)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(5)%' AND def NOT LIKE '%(4)%(5)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(6)%' AND def NOT LIKE '%(5)%(6)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(7)%' AND def NOT LIKE '%(6)%(7)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(8)%' AND def NOT LIKE '%(7)%(8)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(9)%' AND def NOT LIKE '%(8)%(9)%';
SELECT title, pinyin, def FROM combined WHERE def LIKE '%(10)%' AND def NOT LIKE '%(9)%(10)%';
and only one case found (being for "def LIKE '%(1)%' AND def NOT LIKE '%(1)%(2)%'"):
1. 田鼠:  upstream typo ('(2 )' instead of '(2) ').
Check for other cases  of this typo:
SELECT count(*) FROM combined WHERE def LIKE '%(1 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(2 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(3 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(4 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(5 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(6 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(7 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(8 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(9 )%';
SELECT count(*) FROM combined WHERE def LIKE '%(10 )%';
No other cases found (in 2013 November data).*/
-- Manually correct for the additional exceptional case found above:
UPDATE combined SET def = REPLACE(def, '(2 )', '(2) ') WHERE title = '田鼠';
UPDATE combined SET def = REPLACE(def, '(1)', '(1) ') WHERE title = '田鼠';

-- Replace with bracketed character symbols:
UPDATE combined SET def = REPLACE(def, '(1)', '⑴') WHERE def LIKE '%(1)%';
UPDATE combined SET def = REPLACE(def, '(2)', '⑵') WHERE def LIKE '%(2)%';
UPDATE combined SET def = REPLACE(def, '(3)', '⑶') WHERE def LIKE '%(3)%';
UPDATE combined SET def = REPLACE(def, '(4)', '⑷') WHERE def LIKE '%(4)%';
UPDATE combined SET def = REPLACE(def, '(5)', '⑸') WHERE def LIKE '%(5)%';
UPDATE combined SET def = REPLACE(def, '(6)', '⑹') WHERE def LIKE '%(6)%';
UPDATE combined SET def = REPLACE(def, '(7)', '⑺') WHERE def LIKE '%(7)%';
UPDATE combined SET def = REPLACE(def, '(8)', '⑻') WHERE def LIKE '%(8)%';
UPDATE combined SET def = REPLACE(def, '(9)', '⑼') WHERE def LIKE '%(9)%';
UPDATE combined SET def = REPLACE(def, '(10)', '⑽') WHERE def LIKE '%(10)%';

-- 1.b. Process (Western) comma separators (replace with Pleco new line or Chinese list separators):
UPDATE combined SET example = REPLACE(example, ',', '') WHERE example LIKE '%,%';
UPDATE combined SET quote = REPLACE(quote, ',', '') WHERE quote LIKE '%,%';
UPDATE combined SET synonyms = REPLACE(synonyms, ',', '、') WHERE synonyms LIKE '%,%';
UPDATE combined SET antonyms = REPLACE(antonyms, ',', '、') WHERE antonyms LIKE '%,%';
UPDATE combined SET link = REPLACE(link, ',', '') WHERE link LIKE '%,%';

/* 1.c. Replace null entries to empty strings '' for combining/counting later
(otherwise can causes problems with null results, 
especially when using type for counting number of definitions),
and at same time add label for synonyms and antonyms:*/
UPDATE combined SET type = CASE WHEN COALESCE(type, '') = '' THEN '' ELSE type END;
UPDATE combined SET def = CASE WHEN COALESCE(def, '') = '' THEN '' ELSE def END;
UPDATE combined SET example = CASE WHEN COALESCE(example, '') = '' THEN '' ELSE example END;
UPDATE combined SET quote = CASE WHEN COALESCE(quote, '') = '' THEN '' ELSE quote END;
UPDATE combined SET synonyms = CASE WHEN COALESCE(synonyms, '') = '' THEN '' ELSE '似：'||synonyms END;
UPDATE combined SET antonyms = CASE WHEN COALESCE(antonyms, '') = '' THEN '' ELSE '反：'||antonyms END;
UPDATE combined SET link = CASE WHEN COALESCE(link, '') = '' THEN '' ELSE link END;

-- 1.d. Now combine into single field newdef:
ALTER TABLE combined ADD COLUMN newdef;
UPDATE combined SET newdef = '';
UPDATE combined SET newdef = CASE WHEN COALESCE(def, '') = ''
  THEN newdef ELSE def END;
UPDATE combined set newdef = (CASE WHEN COALESCE(example, '') = ''
  THEN newdef ELSE (CASE WHEN COALESCE(newdef, '') = ''
    THEN example ELSE newdef||''||example END) END);
UPDATE combined set newdef = (CASE WHEN COALESCE(quote, '') = ''
  THEN newdef ELSE (CASE WHEN COALESCE(newdef, '') = ''
    THEN quote ELSE newdef||''||quote END) END);
UPDATE combined set newdef = (CASE WHEN COALESCE(synonyms, '') = ''
  THEN newdef ELSE (CASE WHEN COALESCE(newdef, '') = ''
    THEN synonyms ELSE newdef||''||synonyms END) END);
UPDATE combined set newdef = (CASE WHEN COALESCE(antonyms, '') = ''
  THEN newdef ELSE (CASE WHEN COALESCE(newdef, '') = ''
    THEN antonyms ELSE newdef||''||antonyms END) END);
UPDATE combined set newdef = (CASE WHEN COALESCE(link, '') = ''
  THEN newdef ELSE (CASE WHEN COALESCE(newdef, '') = ''
    THEN link ELSE newdef||''||link END) END);

/* 2.a. Add numbering to combined definitions:
order by idx then count up to current id.*/

/* Following command works but now takes hours to complete (previously would only take minutes, strangely):
CREATE TABLE combined2 AS
  SELECT id, title, pinyin, idx, type, newdef,
    (SELECT count(*) FROM combined c2 WHERE c1.title=c2.title AND c1.pinyin=c2.pinyin AND c1.type=c2.type AND c2.id<=c1.id) defid, 
    (SELECT count(*) FROM combined c2 WHERE c1.title=c2.title AND c1.pinyin=c2.pinyin AND c1.type=c2.type) defcount
  FROM combined c1;
This is an SQLite workaround for the lack of ROW_NUMBER function (with PARTITION).
*/
CREATE TABLE combined2a AS
  SELECT c1.id id, c1.title title, c1.pinyin pinyin, c1.idx idx, c1.type type, c1.newdef newdef,
    count(*) defid
  FROM combined c1
  LEFT OUTER JOIN combined c2
    ON (c1.title=c2.title AND c1.pinyin=c2.pinyin AND c1.type=c2.type AND c2.id<=c1.id)
  GROUP BY c1.id;
CREATE TABLE combined2 AS
  SELECT c1.id id, c1.title title, c1.pinyin pinyin, c1.idx idx, c1.type type, c1.newdef newdef,
    c1.defid defid, count(*) defcount
  FROM combined2a c1
  LEFT OUTER JOIN combined c2
    ON (c1.title=c2.title AND c1.pinyin=c2.pinyin AND c1.type=c2.type)
  GROUP BY c1.id;

-- 2.b. Add numbering (only if more than one definition in unique title, pinyin, type):
UPDATE combined2 SET newdef =
  (CASE WHEN defcount<=1 THEN newdef
    ELSE '(@'||defid||'@) '||newdef END);

-- Replace with (unfilled) circled numbers:
UPDATE combined2 SET newdef = REPLACE(newdef, '(@1@)','①') WHERE newdef LIKE '%(@1@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@2@)','②') WHERE newdef LIKE '%(@2@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@3@)','③') WHERE newdef LIKE '%(@3@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@4@)','④') WHERE newdef LIKE '%(@4@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@5@)','⑤') WHERE newdef LIKE '%(@5@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@6@)','⑥') WHERE newdef LIKE '%(@6@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@7@)','⑦') WHERE newdef LIKE '%(@7@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@8@)','⑧') WHERE newdef LIKE '%(@8@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@9@)','⑨') WHERE newdef LIKE '%(@9@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@10@)','⑩') WHERE newdef LIKE '%(@10@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@11@)','⑪') WHERE newdef LIKE '%(@11@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@12@)','⑫') WHERE newdef LIKE '%(@12@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@13@)','⑬') WHERE newdef LIKE '%(@13@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@14@)','⑭') WHERE newdef LIKE '%(@14@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@15@)','⑮') WHERE newdef LIKE '%(@15@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@16@)','⑯') WHERE newdef LIKE '%(@16@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@17@)','⑰') WHERE newdef LIKE '%(@17@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@18@)','⑱') WHERE newdef LIKE '%(@18@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@19@)','⑲') WHERE newdef LIKE '%(@19@)%';
UPDATE combined2 SET newdef = REPLACE(newdef, '(@20@)','⑳') WHERE newdef LIKE '%(@20@)%';
-- Note: MAX(defcount) suggests only need to go up to 19 (for November 2013 data).

-- 3.a. Group by part of speech (title, pinyin, type):
CREATE TABLE combined3 AS
  SELECT title, pinyin, idx, type, defcount, 
    GROUP_CONCAT(newdef, '') newdef3
  FROM (SELECT title, pinyin, idx, type, defcount, newdef
    FROM combined2
    ORDER BY title, pinyin, defid)
  GROUP BY title, pinyin, type;

-- 3.b. Add part of speech (type) count (for determining use of bullet characters):
/* Previously used command, works but very inefficient - now takes hours to complete:
CREATE TABLE combined3a AS
  SELECT title, pinyin, idx, type, defcount, newdef3,
    (SELECT count(*) FROM combined3 c2 WHERE c1.title=c2.title AND c1.pinyin=c2.pinyin) partcount
  FROM combined3 c1;
*/
CREATE TABLE combined3a AS
  SELECT c1.title title, c1.pinyin pinyin, c1.idx idx, c1.type type, c1.defcount defcount, c1.newdef3 newdef3,
    count(*) partcount
  FROM combined3 c1
  LEFT OUTER JOIN combined3 c2
    ON (c1.title=c2.title AND c1.pinyin=c2.pinyin)
  GROUP BY c1.title, c1.pinyin, c1.type;

-- 3.c. Add bullet character if more than one part of speech (type):
ALTER TABLE combined3a ADD COLUMN bullet;
UPDATE combined3a SET bullet = 
  (CASE WHEN partcount>1 
    THEN '◆ '
    ELSE '' END);

-- 3.d. Add part of speech (type), bullets and new lines as appropriate:
UPDATE combined3a SET newdef3 =
  (CASE WHEN COALESCE(type, '') = ''
    THEN bullet||newdef3
    ELSE (CASE WHEN defcount>1
      THEN bullet||'<'||type||'> '||newdef3
      ELSE bullet||'<'||type||'> '||newdef3 END) END);

-- 4. Group by Hanzi/Pinyin (title, pinyin):
CREATE TABLE combined4 AS
  SELECT title, pinyin, GROUP_CONCAT(newdef3, '') newdef4
  FROM (SELECT title, pinyin, idx, type, newdef3
    FROM combined3a
    ORDER BY title, pinyin, idx)
  GROUP BY title, pinyin;

-- 5.a. Replace Chinese brackets with Western brackets in pinyin field (to show in Pleco):
UPDATE combined4 SET pinyin = REPLACE(pinyin, '（', ' (') WHERE pinyin LIKE '%（%';
UPDATE combined4 SET pinyin = REPLACE(pinyin, '）', ') ') WHERE pinyin LIKE '%）%';

-- 5.b. Move bracketed Western names from title (Hanzi) field to start of definition field:
UPDATE combined4 SET 
  newdef4=SUBSTR(title,instr(title,'('))||' '||newdef4,
  title=SUBSTR(title,1,instr(title,'(')-1)
  WHERE title LIKE '%)';

-- 5.c. Remove the square brackets from the non-Unicode characters (for importing to Pleco):
UPDATE combined4 SET title = REPLACE(title, '{[', '{') WHERE title LIKE '%{[%]}%';
UPDATE combined4 SET title = REPLACE(title, ']}', '}') WHERE title LIKE '%{%]}%';

-- 6. Output counts for consistency checking:
SELECT count(*) FROM combined2; -- (unique title, pinyin, type, def) = 213494 (2013 June = 213487);
SELECT count(*) FROM combined3; -- (unique title, pinyin, type) = 171382 (2013 June = 171378);
SELECT count(*) FROM combined4; -- (unique title, pinyin) = 165814 (2013 June = 165810).
