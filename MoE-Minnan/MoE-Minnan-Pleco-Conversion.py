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

    DefString = ""
    HetDefs = Het['definitions']
    for Definition in HetDefs:
      # type, def, examples from definition level:
      CurrentType = Definition['type']
      CurrentDef = Definition['def']
      
      CurrentDefString = "<" + CurrentType + ">" + PLECO_NEW_LINE
      CurrentDefString += CurrentDef

      if 'examples' in Definition:
        ExampleString = ""
        CurrentExamples = Definition['examples']
        for Example in CurrentExamples:
          if ExampleString == "": # should be built-in function for this StrJoin
            ExampleString = Example
          else:
            ExampleString += PLECO_NEW_LINE + Example
        CurrentDefString += PLECO_NEW_LINE + ExampleString

      # add to output definition string
      if DefString == "": # should be built-in function for this StrJoin
        DefString = CurrentDefString
      else: 
        DefString += PLECO_NEW_LINE + CurrentDefString

    # add synonyms if element exists for heteronym
    if 'synonyms' in Het: 
      Syns = Het['synonyms']
      DefString += PLECO_NEW_LINE + "似：" + Syns

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