#!/bin/sh
echo "2015-08-31 MoE-Minnan-Pleco-Conversion Script"
# See "MoE-Minnan-Pleco-Conversion.txt" for associated notes
echo "(requires jshon to process JSON input file)"

DataFile="dict-twblg.json"
OutputFile="MoE-Minnan-flashcards-v01.txt"

PlecoNewLine=""

echo "Input JSON data file: $DataFile"
echo "Output Pleco flashcards file: $OutputFile"

echo "Checking can access input data file..."
if !(test -e "$DataFile"); then
  echo "Error: input file not found - exiting..."
  exit 1
fi
EntryCount=$(jshon -l < "$DataFile")
echo "- Number of entries in input data file = "$EntryCount""
if [ "$EntryCount" -lt 1 ]; then
  echo "Error: expected at least one entry - exiting..."
  exit 1
fi

echo "Creating blank output file (overwrites if exists)..."
printf "" > "$OutputFile"

echo "Looping through and processing input data file entries..."
OutputEntries=0
CurrentEntry=0
# for progress indicator
ProgressStep="$(($EntryCount/100))"
NextProgressOut="$ProgressStep"

EntryCount=20 ### TEMP for TESTING
# this loop is very slow, investigate using jshon -a and/or stack
# serious inefficiency as far too many calls to jshon...
while [ "$CurrentEntry" -lt "$EntryCount" ]
do
  echo "CurrentEntry: "$CurrentEntry""
  # for each entry:

  # title (Hanzi) from entry level:
  Hanzi=$(jshon -e "$CurrentEntry" -e "title" -u < "$DataFile")

  # Looping through heteronyms in entry...
  HeteronymCount=$(jshon -e "$CurrentEntry" -e "heteronyms" -l < "$DataFile")
  CurrentHeteronym=0
  while [ "$CurrentHeteronym" -lt "$HeteronymCount" ]
  do
    echo "CurrentHeteronym: "$CurrentHeteronym""
    # trs (Pronunciation) and synonyms from heteronym level:
    HeteronymID=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "id" -u < "$DataFile")
    Pronunciation=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "trs" -u < "$DataFile")
    # Synonyms=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "synonyms" -u < "$DataFile")

    # Looping through definitions in entry...
    DefinitionCount=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "definitions" -l < "$DataFile")
    CurrentDefinition=0
    DefinitionString=""
    while [ "$CurrentDefinition" -lt "$DefinitionCount" ]
    do
      echo "CurrentDefinition: "$CurrentDefinition""

      Def=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "definitions" -e "$CurrentDefinition" -e "def" -u < "$DataFile")
      Type=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "definitions" -e "$CurrentDefinition" -e "type" -u < "$DataFile")
      CurrentDefString="<"$Type"> "$Def""

      # Looping through examples in definition...
<<TODO
      ExampleCount=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "definitions" -e "$CurrentDefinition" -e "example" -l < "$DataFile")
      CurrentExample=0
      ExampleString=""
      while [ "$CurrentExample" -lt "$ExampleCount" ]
      do
        Example=$(jshon -e "$CurrentEntry" -e "heteronyms" -e "$CurrentHeteronym" -e "definitions" -e "$CurrentDefinition" -e "example" -e "$CurrentExample" -u < "$DataFile")
        
        # increment example-level counter
        CurrentExample="$(($CurrentExample+1))"
      done
TODO
      
      if [ "$DefinitionString" = "" ]; then
        DefinitionString=""$CurrentDefString""
      else
        DefinitionString=""$DefinitionString""$PlecoNewLine""$CurrentDefString""
      fi

      # increment definition-level counter
      CurrentDefinition="$(($CurrentDefinition+1))"
    done

    # Output to flashcard format...
    printf ""$Hanzi"\t@"$Pronunciation"\t$DefinitionString\n" >> "$OutputFile"
    # Note: one Pleco entry created for every entry-heteronym from input
    OutputEntries="$(($OutputEntries+1))"

    # increment heteronym-level counter
    CurrentHeteronym="$(($CurrentHeteronym+1))"
  done

  # increment entry-level counter
  CurrentEntry="$(($CurrentEntry+1))"

  # output progress indicator
  if [ "$CurrentEntry" -eq "$NextProgressOut" ]; then
    echo "- Processing entry "$CurrentEntry" of "$EntryCount"..."
    NextProgressOut="$(($NextProgressOut+$ProgressStep))"
  fi
done

echo "- Entry count (input data file) = "$CurrentEntry""
echo "- Number of processed entries (output flashcards) = "$OutputEntries""

echo "Script completed."
exit 0