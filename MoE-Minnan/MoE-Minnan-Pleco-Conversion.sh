#!/bin/sh
echo "2015-08-31 MoE-Minnan-Pleco-Conversion Script"
# See "MoE-Minnan-Pleco-Conversion.txt" for associated notes
echo "(requires jshon to process JSON input file)"

DataFile="Data/dict-twblg.json"
OutputFile="MoE-Minnan-flashcards-v01.txt"

echo "Checking can access input data file..."
EntryCount=$(jshon -l < $DataFile)
echo "- Number of entries = $EntryCount"
if [ $EntryCount -lt 1 ]; then
  echo "Error: expected at least one entry - exiting..."
  exit 1
fi

echo "Creating blank output file (overwrites if exists)..."
printf "" > $OutputFile

echo "Looping through and processing input data file entries..."
CurrentEntry=0
while [ $CurrentEntry -lt $EntryCount ]
do
  # Looping through heteronyms in entry...

    # Looping through definitions in entry...

  # Output to flashcard format...
  echo $CurrentEntry >> $OutputFile

  CurrentEntry=$(($CurrentEntry+1))
done

echo "- Entry count = $CurrentEntry"

echo "Script completed."
exit 0