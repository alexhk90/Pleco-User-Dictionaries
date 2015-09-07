#!/usr/bin/env python

ScriptVersion = "v03"; ScriptDate = "2015-09-07"
print("MoE-Minnan-Pleco-Conversion Script (" + ScriptVersion + "_" + ScriptDate + ")")
# See "MoE-Minnan-Pleco-Conversion.txt" for associated notes

NUMERIC_TONES = True # output version with diacritic tones to converted to numeric
CLEANSE_DEF = True # cleanse some minor upstream data issues

if NUMERIC_TONES:
  import TWRomanisation
  ToneToNumeric = TWRomanisation.LineDiacriticToNumeric
  OutputFile = "MoE-Minnan-flashcards-" + ScriptVersion + "-numeric.txt"
else:
  OutputFile = "MoE-Minnan-flashcards-" + ScriptVersion + ".txt"

# load data from json
import json
DataFile = "dict-twblg.json"

PLECO_NEW_LINE = ""
DEF_NUMBERS = ['①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑮','⑰','⑱','⑲','⑳']

print("Input JSON data file:", DataFile)
print("Output Pleco flashcards file:", OutputFile)

print("Loading input data file...");
Entries = json.load(open(DataFile))

print("- Number of entries in input data file = {0}".format(len(Entries)))

print("Creating blank output file (overwrites if exists)...")
FileOut = open(OutputFile, "w")

print("Looping through and processing input data file entries...")
EntriesProcessed = 0
EntriesOutput = 0
for Entry in Entries:
  # parse entry and output to Pleco flashcards (one per entry-heteronym)

  # title (Hanzi) from entry level:
  Hanzi = Entry['title'] 

  # Looping through heteronyms in entry...
  EntryHets = Entry['heteronyms']
  for Het in EntryHets:
    # trs (Pronunciation) and synonyms from heteronym level:
    Pinyin = Het['trs']
    if NUMERIC_TONES:
      Pinyin = ToneToNumeric(Pinyin)

    # heteronym (output entry) level string
    DefStrings = []
    DefNo = 0
    HetDefs = Het['definitions']
    DefCount = len(HetDefs)
    for Definition in HetDefs:      
      # definition level string
      CurrentDefString = ""

      # numbering
      if DefCount > 1:
        CurrentDefString += DEF_NUMBERS[DefNo] + " "
        DefNo += 1

      # type, def, examples from definition level:
      CurrentType = Definition['type']
      if CurrentType != "":
        CurrentDefString += "<" + CurrentType + ">" + " "

      CurrentDef = Definition['def']
      if CLEANSE_DEF:
        # cleanse definition string (minor upstream data issues)
        import re
        # - as of version commited to moedict-data-twblg on Jan 1, 2015:
        # 3 complete <font class=tlsound>...</font> tags
        CurrentDef = re.sub('<font.*?>(.*?)</font>', r'\1', CurrentDef)
        # 2 incomplete ...> tags ("nt class=tlsound>" and "ont>"
        CurrentDef.replace("nt class=tlsound>", "")
        CurrentDef.replace("ont>", "")

      # ### TODO: numeric tones for CurrentDef and ExampleString 

      CurrentDefString += CurrentDef

      if 'example' in Definition:
        CurrentExamples = Definition['example']
        ExampleSeparator = PLECO_NEW_LINE + "如："
        ExampleString = ExampleSeparator + ExampleSeparator.join(CurrentExamples)
        CurrentDefString += ExampleString

      DefStrings.append(CurrentDefString)

    # collect and join output definition strings
    DefString = PLECO_NEW_LINE.join(DefStrings)

    if 'synonyms' in Het: 
      Syns = Het['synonyms']
      DefString += PLECO_NEW_LINE + "似：" + Syns

    # Output to flashcard format...
    CardString = Hanzi + "\t" + "@" + Pinyin + "\t" + DefString + "\n"
    FileOut.write(CardString)
    EntriesOutput += 1
    # Note: one Pleco entry created for every entry-heteronym from input

  EntriesProcessed += 1

# FileOut.close()

print("- Input entries processed (input data file) = {0}".format(EntriesProcessed))
print("- Number of resulting Pleco entries (output flashcards) = {0}".format(EntriesOutput))

print("MoE-Minnan-Pleco-Conversion Script Completed.")
exit(0)