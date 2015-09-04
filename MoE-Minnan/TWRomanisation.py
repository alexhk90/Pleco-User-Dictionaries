#!/usr/bin/env python
# Taiwanese Romanisation helper functions module

import json
MappingDataFile = "Taiwanese-Romanisation-tones.json"
RawMappingData = json.load(open(MappingDataFile))

# convert data from vowel to character and diacritic to character to vowel and diacritic
RawVowelMapping = RawMappingData['vowels']
CharacterVowelMapping = CharacterToneMapping = {}
for Vowel in RawVowelMapping:
  VowelCharacter = RawVowelMapping[Vowel]
  for Character in VowelCharacter:
    # add to mapping from character
    # print( Character + " = " + Vowel + "-" + VowelCharacter[Character] )
    CharacterVowelMapping[Character] = Vowel
    CharacterToneMapping[Character] = VowelCharacter[Character]

DiacriticToneMapping = RawMappingData['diacritics']
ToneNumeralMapping = RawMappingData['tones']

# convert single word from diacritic tone to numeric
# assumes at most one diacritic in the word
def WordDiacriticToNumeric(Word):
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
    NewWord += "{0}".format(Numeral)
  elif type(Numeral) is list:
    for StopLetter in Numeral[0].keys():
      if( Word[len(Word)-1] == StopLetter ):
        NewWord += "{0}".format(Numeral[0][StopLetter])
        break
    else:
      NewWord += "{0}".format(Numeral[1])
  else:
    print( "unexpected tones object structure" )

  return NewWord

# convert line (sentence) from diacritic tone to numeric
# uses WordDiacriticToNumeric
def LineDiacriticToNumeric(Line):
  WORD_SEPARATOR = " "

  # split line into individual words
  LineWords = Line.split(WORD_SEPARATOR)

  # ### take into account - and --

  # ### take into account punctuation

  # convert each word in line array
  NewLineWords = []
  for Word in LineWords:
    # ### recurse here?
    NewWord = WordDiacriticToNumeric(Word)
    NewLineWords.append(NewWord)

  # re-join into new line
  NewLine = WORD_SEPARATOR.join(NewLineWords)

  return NewLine

#TestWord = "lân"
TestLine = "Khuànn-tio̍h tsit khuán lâng tō gê"
TestWord = "tō"

print( WordDiacriticToNumeric(TestWord) )
print( LineDiacriticToNumeric(TestLine) )