#!/bin/bash
echo "20150123 Conversion-Simp03"
# - Traditional to Simplified Chinese Character Conversion.
# - Specifically for MoEDict (headwords), but should be easy enough to generalise.
# - Merged 20130714 Conversion-Simp02a with 20130831 Conversion-Simp03-Unihan.
# - (See 20130831 Conversion-Simp03-Unihan for merging of Unihan data with other source data.)
# - The resulting tables have been output as the current "Conversion-*.csv" files.
# - Run this bash script file in same folder as input files below.

# - Filenames currently refer to "MoEDict-05", change for other versions/input.
dbfile="MoEDict-05-Simp03.sqlite3"
sqlfile="Conversion-Temp.sql"
inputcards="MoEDict-05-cards.txt"
outputcards="MoEDict-05-Simp03-cards.txt"
inputalways="Conversion-Always.csv"
inputalwaysif="Conversion-If.csv"
inputalwaysifnot="Conversion-IfNot.csv"
inputalwaysnot="Conversion-AlwaysNot.csv"
runchecks=0 # - Set to 1 to skip Conversion-Always run manual checks for If and IfNot.

echo "0. Collect and format data."
# - (See Archive (Conversion.ods, feng, SayJack, Unihan) files for one-time processing of input data.)
# - $inputalways has characters to always convert.
# - $inputalwaysif has characters to convert if Pinyin matches.
# - $inputalwaysifnot has characters to convert if Pinyin does not match.
# - $inputalwaysnot has characters to not convert (used during input processing, but not here).

echo "- Creating new database file [$dbfile]..."
cat /dev/null > $dbfile

# - Importing conversion tables:
cat >$sqlfile <<SQLCOMMANDS
.separator '|'
CREATE TABLE Always (Traditional,Simplified,Source,Notes);
.import $inputalways Always
CREATE TABLE AlwaysIf (Traditional,Simplified,Source,Pinyin);
.import $inputalwaysif AlwaysIf
CREATE TABLE AlwaysIfNot (Traditional,Simplified,Source,Pinyin);
.import $inputalwaysifnot AlwaysIfNot
CREATE TABLE AlwaysNot (Traditional,Simplified,Source);
.import $inputalwaysnot AlwaysNot
SQLCOMMANDS
# - Import dictionary data, and duplicate (Traditional) title:
cat >>$sqlfile <<SQLCOMMANDS
.mode tabs
CREATE TABLE dict (title,pinyin,def);
.import $inputcards dict
ALTER TABLE dict ADD COLUMN simptitle;
UPDATE dict SET simptitle=title;
SQLCOMMANDS
echo "- Importing conversion tables and dictionary data [$inputcards]..."
sqlite3 $dbfile < $sqlfile

echo "1. Conversion-Always [$inputalways]."
# - Loop through Conversion-Always doing a search/replace for the conversion (Traditional to Simplified).
echo "- Generating REPLACE statements for Conversion-Always..."
cat /dev/null > $sqlfile
minrow=$(sqlite3 $dbfile "SELECT MIN(rowid) FROM Always;")
maxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) FROM Always;")
for (( j=minrow; j<=maxrow; j++ )); do
  trad=$(sqlite3 $dbfile "SELECT Traditional FROM Always WHERE rowid=$j;")
  simp=$(sqlite3 $dbfile "SELECT Simplified FROM Always WHERE rowid=$j;")
  sqlstring="UPDATE dict SET simptitle = REPLACE(simptitle,'$trad','$simp') WHERE simptitle LIKE '%$trad%';"
#  echo $j' of '$maxrow': 'sqlite3 $dbfile '"'$sqlstring'"';
#  sqlite3 $dbfile "$sqlstring";
  echo $sqlstring >> $sqlfile
done
((rowcount=$maxrow-$minrow+1))
if [ $runchecks -ne 1 ]; then
  echo "- Running REPLACE statements ($rowcount cases) for Conversion-Always..."
  sqlite3 $dbfile < $sqlfile
fi

echo "2. Conversion-If  [$inputalwaysif]."
# Create temporary table with character position (charpos) field 
#   and then extract the relevant pinyin by looping through rows of this temporary table.
#   Compare this extracted pinyin to decide whether or not to replace for this entry.
echo "- Generating REPLACE statements for Conversion-If..."
cat /dev/null > $sqlfile
rowcount=0
iminrow=$(sqlite3 $dbfile "SELECT MIN(rowid) FROM AlwaysIf;")
imaxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) FROM AlwaysIf;")
for (( i=iminrow; i<=imaxrow; i++ )); do
  trad=$(sqlite3 $dbfile "SELECT Traditional FROM AlwaysIf WHERE rowid=$i;")
  simp=$(sqlite3 $dbfile "SELECT Simplified FROM AlwaysIf WHERE rowid=$i;")
  pinyin=$(sqlite3 $dbfile "SELECT Pinyin FROM AlwaysIf WHERE rowid=$i;")

  sqlite3 $dbfile "CREATE TABLE iftemp AS
    SELECT title, INSTR(title,'$trad') charpos, pinyin, pinyin AS pychar, rowid AS id FROM dict WHERE title LIKE '%$trad%';"

  jminrow=$(sqlite3 $dbfile "SELECT MIN(rowid) FROM iftemp;")
  jmaxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) FROM iftemp;")
  for (( j=jminrow; j<=jmaxrow; j++ )); do
    pytemp=$(sqlite3 $dbfile "SELECT pinyin FROM iftemp WHERE rowid=$j;")
    charpos=$(sqlite3 $dbfile "SELECT charpos FROM iftemp WHERE rowid=$j;")
    pyarr=($pytemp)
    pychar=${pyarr[charpos-1]}
    sqlite3 $dbfile "UPDATE iftemp SET pychar = '$pychar' WHERE rowid=$j;"

#    title=$(sqlite3 $dbfile "SELECT title FROM iftemp WHERE rowid=$j")
#    echo $i' of '$imaxrow' ('$trad' to '$simp'), '$j' of '$jmaxrow': '$title' ('$pytemp'): comparing '$pinyin' with '$pychar;
    if [[ "$pychar" == "$pinyin"* ]]; then
      idtemp=$(sqlite3 $dbfile "SELECT id FROM iftemp WHERE rowid=$j");
#      sqlstring="UPDATE dict SET simptitle = REPLACE(simptitle, '$trad','$simp') WHERE title='$title' AND pinyin='$pytemp';"
      sqlstring="UPDATE dict SET simptitle = REPLACE(simptitle, '$trad','$simp') WHERE rowid=$idtemp;"
#      echo sqlite3 $dbfile '"'$sqlstring'"'
#      sqlite3 $dbfile "$sqlstring"
      echo $sqlstring >> $sqlfile
      ((rowcount++))
#    else
#      echo '(pinyin does not match - do not convert)'
    fi
  done

  sqlite3 $dbfile "DROP TABLE iftemp;"
done
((icount=$imaxrow-$iminrow+1))
echo "- Running REPLACE statements ($rowcount across $icount cases) for Conversion-If..."
sqlite3 $dbfile < $sqlfile

# manual checks:
if [ $runchecks -eq 1 ]; then
  echo "- Running manual checks for Conversion-If..."
  iminrow=$(sqlite3 $dbfile "SELECT MIN(rowid) from AlwaysIf;")
  imaxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) from AlwaysIf;")
  for (( i=iminrow; i<=imaxrow; i++ )); do
    trad=$(sqlite3 $dbfile "SELECT Traditional FROM AlwaysIf WHERE rowid=$i;")
    simp=$(sqlite3 $dbfile "SELECT Simplified FROM AlwaysIf WHERE rowid=$i;")
    pinyin=$(sqlite3 $dbfile "SELECT Pinyin FROM AlwaysIf WHERE rowid=$i;")
  
    replaced=$(sqlite3 $dbfile "SELECT count(*) FROM dict WHERE title LIKE '%$trad%' and simptitle LIKE '%$simp%';")
    total=$(sqlite3 $dbfile "SELECT count(*) FROM dict WHERE title LIKE '%$trad%'")
    echo $i' of '$imaxrow': '$trad' to '$simp' ('$pinyin'): replaced '$replaced' of '$total
  
    echo 'not replaced, expected replaced:'
    sqlite3 $dbfile "SELECT title,pinyin,simptitle FROM dict WHERE title LIKE '%$trad%' AND pinyin LIKE '%$pinyin%' AND simptitle NOT LIKE '%$simp%';"
    echo 'replaced, expected not replaced:'
    sqlite3 $dbfile "SELECT title,pinyin,simptitle FROM dict WHERE title LIKE '%$trad%' AND pinyin NOT LIKE '%$pinyin%' AND simptitle LIKE '%$simp%';"
  done
fi
# fix exceptions from above:
# - 千里之堤，潰於蟻穴|qiān lǐ zhī tí kuì yú yǐ xuè|千里之堤，潰於蟻穴
# - 千里之行，始於足下|qiān lǐ zhī xíng shǐ yú zú xià|千里之行，始於足下
# - 己所不欲，勿施於人|jǐ suǒ bù yù wù shī yú rén|己所不欲，勿施於人
# - 老龜煮不爛，移禍於枯桑|lǎo guī zhǔ bù làn yí huò yú kū sāng|老龜煮不爛，移禍於枯桑
# - 運用之妙，在於一心|yùn yòng zhī miào zài yú yī xīn|運用之妙，在於一心
# - 防人之口，甚於防川|fáng rén zhī kǒu shèn yú fáng chuān|防人之口，甚於防川
# - 防民之口，甚於防川|fáng mín zhī kǒu shèn yú fáng chuān|防民之口，甚於防川
# these are all due to the punctuation shifting the character position
# manual inspection of above indicates all should be replaced:
echo "- Fixing exceptions for Conversion-If (from manual checks, see script)..."
cat >$sqlfile <<SQLCOMMANDS
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='千里之堤，潰於蟻穴' AND pinyin='qiān lǐ zhī tí kuì yú yǐ xuè';
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='千里之行，始於足下' AND pinyin='qiān lǐ zhī xíng shǐ yú zú xià';
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='己所不欲，勿施於人' AND pinyin='jǐ suǒ bù yù wù shī yú rén';
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='老龜煮不爛，移禍於枯桑' AND pinyin='lǎo guī zhǔ bù làn yí huò yú kū sāng';
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='運用之妙，在於一心' AND pinyin='yùn yòng zhī miào zài yú yī xīn';
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='防人之口，甚於防川' AND pinyin='fáng rén zhī kǒu shèn yú fáng chuān';
UPDATE dict SET simptitle = REPLACE(simptitle, '於','于') WHERE title='防民之口，甚於防川' AND pinyin='fáng mín zhī kǒu shèn yú fáng chuān';
SQLCOMMANDS
sqlite3 $dbfile < $sqlfile
# re-running manual exception check above should now lead to zero exceptions


echo "3. Conversion-IfNot [$inputalwaysifnot]."
# - (as above but replace AlwaysIf with AlwaysIfNot and LIKE with NOT LIKE when comparing pinyin in temporary table for each row in AlwaysIfNot)
echo "- Generating REPLACE statements for Conversion-IfNot..."
cat /dev/null > $sqlfile
rowcount=0
iminrow=$(sqlite3 $dbfile "SELECT MIN(rowid) from AlwaysIfNot;")
imaxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) from AlwaysIfNot;")
for (( i=iminrow; i<=imaxrow; i++ )); do
  trad=$(sqlite3 $dbfile "SELECT Traditional FROM AlwaysIfNot WHERE rowid=$i;")
  simp=$(sqlite3 $dbfile "SELECT Simplified FROM AlwaysIfNot WHERE rowid=$i;")
  pinyin=$(sqlite3 $dbfile "SELECT Pinyin FROM AlwaysIfNot WHERE rowid=$i;")

  sqlite3 $dbfile "CREATE TABLE iftemp AS
    SELECT title, INSTR(title,'$trad') AS charpos, pinyin, pinyin AS pychar, rowid AS id FROM dict WHERE title LIKE '%$trad%';"

  jminrow=$(sqlite3 $dbfile "SELECT MIN(rowid) FROM iftemp;")
  jmaxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) FROM iftemp;")
  for (( j=jminrow; j<=jmaxrow; j++ )); do
    pytemp=$(sqlite3 $dbfile "select pinyin FROM iftemp WHERE rowid=$j;")
    charpos=$(sqlite3 $dbfile "select charpos FROM iftemp WHERE rowid=$j;")
    pyarr=($pytemp)
    pychar=${pyarr[charpos-1]}
    sqlite3 $dbfile "UPDATE iftemp SET pychar = '$pychar' WHERE rowid=$j;"

#    title=$(sqlite3 $dbfile "SELECT title FROM iftemp WHERE rowid=$j")
#    echo $i' of '$imaxrow' ('$trad' to '$simp'), '$j' of '$jmaxrow': '$title' ('$pytemp'): comparing '$pinyin' with '$pychar
    if [[ "$pychar" != "$pinyin"* ]]; then
      idtemp=$(sqlite3 $dbfile "SELECT id FROM iftemp WHERE rowid=$j");
      sqlstring="UPDATE dict SET simptitle = REPLACE(simptitle, '$trad','$simp') WHERE rowid=$idtemp;"
#      sqlstring="UPDATE dict SET simptitle = REPLACE(simptitle, '$trad','$simp') WHERE title='$title' AND pinyin='$pytemp';"
#      echo sqlite3 $dbfile '"'$sqlstring'"'
#      sqlite3 $dbfile "$sqlstring"
      echo $sqlstring >> $sqlfile
      ((rowcount++))
#    else
#      echo '(pinyin matches - do not convert)';
    fi
  done

  sqlite3 $dbfile "DROP TABLE iftemp;"
done
((icount=$imaxrow-$iminrow+1))
echo "- Running REPLACE statements ($rowcount across $icount cases) for Conversion-IfNot..."
sqlite3 $dbfile < $sqlfile

# manual checks:
if [ $runchecks -eq 1 ]; then
  echo "- Running manual checks for Conversion-IfNot..."
  iminrow=$(sqlite3 $dbfile "SELECT MIN(rowid) from AlwaysIfNot;")
  imaxrow=$(sqlite3 $dbfile "SELECT MAX(rowid) from AlwaysIfNot;")
  for (( i=iminrow; i<=imaxrow; i++ )); do
    trad=$(sqlite3 $dbfile "SELECT Traditional FROM AlwaysIfNot WHERE rowid=$i;")
    simp=$(sqlite3 $dbfile "SELECT Simplified FROM AlwaysIfNot WHERE rowid=$i;")
    pinyin=$(sqlite3 $dbfile "SELECT Pinyin FROM AlwaysIfNot WHERE rowid=$i;")
  
    replaced=$(sqlite3 $dbfile "SELECT count(*) FROM dict WHERE title LIKE '%$trad%' AND simptitle LIKE '%$simp%';")
    total=$(sqlite3 $dbfile "SELECT count(*) FROM dict WHERE title LIKE '%$trad%'")
    echo $i' of '$imaxrow': '$trad' to '$simp' ('$pinyin'): replaced '$replaced' of '$total
  
    echo 'not replaced, expected replaced:'
    sqlite3 $dbfile "SELECT title,pinyin,simptitle FROM dict WHERE title LIKE '%$trad%' AND pinyin NOT LIKE '%$pinyin%' AND simptitle NOT LIKE '%$simp%';"
    echo 'replaced, expected not replaced:'
    sqlite3 $dbfile "SELECT title,pinyin,simptitle FROM dict WHERE title LIKE '%$trad%' AND pinyin LIKE '%$pinyin%' AND simptitle LIKE '%$simp%';"
  done
fi

# manually fix exceptions from above:
# (note some of the exceptions are due to pinyin of other characters, these are omitted from the following)
# - 防人之口，甚於防川|fáng rén zhī kǒu shèn yú fáng chuān|防人之口，什于防川
# - 防民之口，甚於防川|fáng mín zhī kǒu shèn yú fáng chuān|防民之口，什于防川
# again these are all due to the punctuation shifting the character position
# manual inspection of above indicates all (of above) should be replaced:
if [ $runchecks -ne 1 ]; then
  echo "- Fixing exceptions for Conversion-IfNot (from manual checks, see script)..."
fi
cat >$sqlfile <<SQLCOMMANDS
UPDATE dict SET simptitle = REPLACE(simptitle, '什','甚') WHERE title='防人之口，甚於防川' AND pinyin='fáng rén zhī kǒu shèn yú fáng chuān';
UPDATE dict SET simptitle = REPLACE(simptitle, '什','甚') WHERE title='防民之口，甚於防川' AND pinyin='fáng mín zhī kǒu shèn yú fáng chuān';
SQLCOMMANDS
if [ $runchecks -ne 1 ]; then
  sqlite3 $dbfile < $sqlfile
fi
# re-running manual exception check should now lead to zero true exceptions 
# (as mentioned before will be some (5 for MoEDict-05-Simp05) due to other matching pinyin of other characters)

# 4. Conversion-AlwaysNot.
# (can use to generate list of unconsidered characters, i.e. not in any of the Conversion-* tables)
# (not yet implemented)

if [ $runchecks -ne 1 ]; then
  echo "5. Output to Pleco flashcard format [$outputcards]."
# check number of headwords converted
  echo "- Conversion Count:" $(sqlite3 $dbfile "SELECT count(*) FROM dict WHERE title!=simptitle;")
# 101440 (for MoEDict-04c-Simp02b)
# 102052 (for MoEDict-04c-Simp03 and MoEDict-05-Simp03)
fi
cat >$sqlfile <<SQLCOMMANDS
.mode tabs
.output $outputcards
select simptitle||'['||title||']',pinyin,def from dict;
SQLCOMMANDS
if [ $runchecks -ne 1 ]; then
  sqlite3 $dbfile < $sqlfile
fi

echo "6. Clean up and exit."

# delete temporary file
rm $sqlfile

exit 0