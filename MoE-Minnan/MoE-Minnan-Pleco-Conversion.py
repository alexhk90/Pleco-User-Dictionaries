#!/usr/bin/env python
print( "2015-09-02 MoE-Minnan-Pleco-Conversion Script" )
# See "MoE-Minnan-Pleco-Conversion.txt" for associated notes

# use Python json module
import json

DataFile = "dict-twblg.json"
OutputFile = "MoE-Minnan-flashcards-v01.txt"

PLECO_NEW_LINE = ""

print( "Input JSON data file:", DataFile )
print( "Output Pleco flashcards file:", OutputFile )

print( "Loading input data file..." );
Entries = json.load( open( DataFile ) )

print( "- Number of entries in input data file = ", len( Entries ) )

print( "Creating blank output file (overwrites if exists)..." )
FileOut = open( OutputFile, "w" )

print( "Looping through and processing input data file entries..." )
EntriesProcessed = 0
EntriesOutput = 0
for Entry in Entries:
  # parse entry and output to Pleco flashcards

  # title (Hanzi) from entry level:
  Hanzi = Entry['title'] 

  # Looping through heteronyms in entry...
  EntryHets = Entry['heteronyms']
  for Het in EntryHets:
    # trs (Pronunciation) and synonyms from heteronym level:
    Pinyin = Het['trs']
    if 'synonyms' in Het: 
      Syns = Het['synonyms']
      # print( "Synonyms: ", Syns )

    DefString = ""
    HetDefs = Het['definitions']
    for Definition in HetDefs:
      if DefString == "": # should be function for this StrJoin
        DefString = Definition['def']
      else: 
        DefString += PLECO_NEW_LINE + Definition['def']

    # Output to flashcard format...
    CardString = Hanzi + "\t" + "@" + Pinyin + "\t" + DefString + "\n"
    FileOut.write( CardString )
    EntriesOutput += 1
    # Note: one Pleco entry created for every entry-heteronym from input

  EntriesProcessed += 1

# FileOut.close( )

print( "- Input entries processed (input data file) = ", EntriesProcessed )
print( "- Number of resulting Pleco entries (output flashcards) = ", EntriesOutput )

print( "MoE-Minnan-Pleco-Conversion Script Completed." )
exit( 0 )