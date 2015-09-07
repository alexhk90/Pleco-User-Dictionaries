#!/usr/bin/env python
# Taiwanese Romanisation helper functions module
# - diacritic to numeric tone function

# load diacritic tone to numeral mapping from data file
import json
MappingDataFile = "Taiwanese-Romanisation-tones.json"
RawMappingData = json.load(open(MappingDataFile))
DiacriticToneMapping = RawMappingData['diacritics']
ToneNumeralMapping = RawMappingData['tones']
LineSeparators = RawMappingData['separators']
# 'punctuation' list populated using following command:
# "sed 's/\(.\)/\1\n/g' [filename] | sort | uniq -c"
# where [filename] = ("MoE-Minnan-flashcards-v03.txt","dict-twblg.json")
LinePunctuation = RawMappingData['punctuation']
# both lists currently handled in same way
WordSeparators = LineSeparators + LinePunctuation

# convert single word from diacritic tone to numeric
# - assumes at most one diacritic in the word
def WordDiacriticToNumeric(Word):
  # check if blank (occurs when splitting by punctuation)
  if len(Word) < 1:
    return Word

  # check for diacritic in word
  for Diacritic in DiacriticToneMapping:
    if Diacritic in Word:
      break
  else:
    Diacritic = ""
    Tone = "none"

  # remove diacritic
  NewWord = Word
  if Diacritic != "":
    NewWord = NewWord.replace(Diacritic, "", 1)
    Tone = DiacriticToneMapping[Diacritic]

  # append appropriate numeral
  Numeral = ToneNumeralMapping[Tone]
  if type(Numeral) is int:
    # simple mapping from tone to numeral
    NewWord += "{0}".format(Numeral)
  elif type(Numeral) is list:
    # list mapping:
    # - first element by last letter
    # - second element for all other last letters
    # check last letter
    LastLetter = Word[len(Word)-1]
    for StopLetter in Numeral[0].keys():
      if( LastLetter == StopLetter ):
        # matches stop letter (in first element)
        NewWord += "{0}".format(Numeral[0][StopLetter])
        break
    else:
      # does not match last letter
      NewWord += "{0}".format(Numeral[1])
  else:
    print( "unexpected tones object structure" )

  return NewWord

# convert line (sentence) from diacritic tone to numeric
# - uses WordDiacriticToNumeric
# - recurses through all characters in WordSeparators,
#   splitting the line segments using each character,
#   effectively ignoring but maintaining these characters
def LineDiacriticToNumeric(Line, SeparatorNo):
  # current separator (start at 0 and recurse)
  Separator = WordSeparators[SeparatorNo]

  # split line into individual words (or line-segments)
  LineWords = Line.split(Separator)

  # next separator
  SeparatorNo += 1 # move to next separator for recursion
  MoreSeparators = (SeparatorNo < len(WordSeparators))
  if MoreSeparators:
    NextSeparator = WordSeparators[SeparatorNo]

  # convert each word in line array
  NewLineWords = []
  for Word in LineWords:
    # recurse through separators until reaches end of list
    if MoreSeparators:
      NewWord = LineDiacriticToNumeric(Word, SeparatorNo)
    else:
      NewWord = WordDiacriticToNumeric(Word)
    NewLineWords.append(NewWord)

  # re-join into new line
  NewLine = Separator.join(NewLineWords)

  return NewLine

# test diacritic tone to numeric conversion
def TestDiacriticToNumeric():
  TestLines = []
  TestLines.append("Khuànn-tio̍h tsit khuán lâng tō gê")
  TestLines.append("Kè-á tu khah kuè--khì--leh.")
  TestLines.append("Kā phue̍h tsānn--khí-lâi.")
  TestLines.append("Hit nn̄g uân oo-oo ê mi̍h-kiānn sī siánn-mih?")
  TestLines.append("Honnh, guân-lâi sī án-ne--ooh!")
  TestLines.append("Tsa-bóo khiā tsit pîng, tsa-poo khiā hit pîng.")
  TestCount = 0
  for TestLine in TestLines:
    TestCount += 1
    print( "{0}: ".format(TestCount) + TestLine )
    print( LineDiacriticToNumeric(TestLine, 0) )
#TestDiacriticToNumeric()