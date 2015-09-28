#!/usr/bin/env python
# Taiwanese Romanisation helper functions module
# - diacritic to numeric tone function

import json, re

# load diacritic tone to numeral mapping from data file
MappingDataFile = "Taiwanese-Romanisation-tones.json"
RawMappingData = json.load(open(MappingDataFile))
DiacriticToneMapping = RawMappingData['diacritics']
ToneNumeralMapping = RawMappingData['tones']
LineSeparators = RawMappingData['separators']
# 'punctuation' list populated using following command:
# "sed 's/\(.\)/\1\n/g' [filename] | sort | uniq -c"
# where [filename] = ("MoE-Minnan-flashcards-v04.txt","dict-twblg.json")
LinePunctuation = RawMappingData['punctuation']
# both lists currently handled in same way
WordSeparators = LineSeparators + LinePunctuation

# convert single word from diacritic tone to numeric
# - assumes at most one diacritic in the word
def WordDiacriticToNumeric(Word):
  # check if blank (occurs when splitting by punctuation)
  if len(Word) < 1:
    return Word

  # check if no letters (a-z or A-Z) in word (e.g. all Chinese characters)
  if not re.search('[a-zA-Z]', Word):
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

  # check for non-alpha final character (not a-z or A-Z; e.g. Chinese)
  # note: all the WordSeparators should already be checked by this point
  #   and all the known diacritics have been removed (above)
  AppendWord = ""
  if not re.search('[a-zA-Z]$', NewWord):
    # does not end in alpha so add non-alpha section separately
    TEMP_SEPARATOR = "@"
    # split such that alpha in first section and rest in second section
    WordSplit = re.sub('([a-zA-Z]+)(.+?)', r'\1'+TEMP_SEPARATOR+r'\2', NewWord)
    WordArray = WordSplit.split(TEMP_SEPARATOR)
    # continue with first section
    NewWord = WordArray[0]
    # add second section to string to be appended after numeral
    AppendWord += WordArray[1]

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

  # append additional non-alpha characters
  # (part of logic to place numerals directly after alpha characters)
  NewWord += AppendWord

  return NewWord

# convert line (sentence) from diacritic tone to numeric
# - uses WordDiacriticToNumeric
# - recurses through all characters in WordSeparators,
#   splitting the line segments using each character,
#   effectively ignoring but maintaining these characters
def LineDiacriticToNumeric(Line, SeparatorNo=0):
  # current separator (start at 0 and recurse)
  Separator = WordSeparators[SeparatorNo]

  # split line into individual words (or line-segments)
  LineWords = Line.split(Separator)

  # move to next separator for recursion
  SeparatorNo += 1
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
    # add to processed words / line-segments
    NewLineWords.append(NewWord)

  # re-join processed words into new line
  NewLine = Separator.join(NewLineWords)

  return NewLine

# test cases for diacritic tone to numeric conversion (uncomment after to run)
# - asserts for expected results
def TestDiacriticToNumeric():
  TestLines = []
  ExpectedLines = []
  TestLines.append("Khuànn-tio̍h tsit khuán lâng tō gê")
  ExpectedLines.append("Khuann3-tioh8 tsit4 khuan2 lang5 to7 ge5")
  TestLines.append("Kè-á tu khah kuè--khì--leh.")
  ExpectedLines.append("Ke3-a2 tu1 khah4 kue3--khi3--leh4.")
  TestLines.append("Kā phue̍h tsānn--khí-lâi.")
  ExpectedLines.append("Ka7 phueh8 tsann7--khi2-lai5.")
  TestLines.append("Hit nn̄g uân oo-oo ê mi̍h-kiānn sī siánn-mih?")
  ExpectedLines.append("Hit4 nng7 uan5 oo1-oo1 e5 mih8-kiann7 si7 siann2-mih4?")
  TestLines.append("Honnh, guân-lâi sī án-ne--ooh!")
  ExpectedLines.append("Honnh4, guan5-lai5 si7 an2-ne1--ooh4!")
  TestLines.append("Tsa-bóo khiā tsit pîng, tsa-poo khiā hit pîng.")
  ExpectedLines.append("Tsa1-boo2 khia7 tsit4 ping5, tsa1-poo1 khia7 hit4 ping5.")
  TestLines.append("￹㔂甘蔗￺lân kam-tsià￻削掉甘蔗的外皮節眼、籜葉")
  ExpectedLines.append("￹㔂甘蔗￺lan5 kam1-tsia3￻削掉甘蔗的外皮節眼、籜葉")
  TestLines.append("￹看著這款人就㤉。￺Khuànn-tio̍h tsit khuán lâng tō gê. ￻看到這種人就討厭。")
  ExpectedLines.append("￹看著這款人就㤉。￺Khuann3-tioh8 tsit4 khuan2 lang5 to7 ge5. ￻看到這種人就討厭。")
  TestLines.append("￹講無兩句話伊就共我㧌落去矣。￺Kóng bô nn̄g kù uē i tō kā guá mau--lo̍h-khì--ah. ￻講沒兩句話他就揍我了。")
  ExpectedLines.append("￹講無兩句話伊就共我㧌落去矣。￺Kong2 bo5 nng7 ku3 ue7 i1 to7 ka7 gua2 mau1--loh8-khi3--ah4. ￻講沒兩句話他就揍我了。")
  TestLines.append("凹陷。伊的車門予人挵一㧌。I ê tsia-mn̂g hōo lâng lòng tsi̍t mau. (他的車門被撞了個凹陷。)")
  ExpectedLines.append("凹陷。伊的車門予人挵一㧌。I1 e5 tsia1-mng5 hoo7 lang5 long3 tsit8 mau1. (他的車門被撞了個凹陷。)")
  TestLines.append("人共伊歹，伊毋但毋驚，閣敢佮人㧣。￺Lâng kā i pháinn, i m̄-nā m̄ kiann, koh kánn kah lâng tu.￻別人兇他，他不但不怕，還與人爭辯。")
  ExpectedLines.append("人共伊歹，伊毋但毋驚，閣敢佮人㧣。￺Lang5 ka7 i1 phainn2, i1 m7-na7 m7 kiann1, koh4 kann2 kah4 lang5 tu1.￻別人兇他，他不但不怕，還與人爭辯。")
  TestLines.append("￹喙㧣遐懸創啥？￺Tshuì tu hiah kuân tshòng siánn? ￻嘴撅那麼高做什麼？")
  ExpectedLines.append("￹喙㧣遐懸創啥？￺Tshui3 tu1 hiah4 kuan5 tshong3 siann2? ￻嘴撅那麼高做什麼？")
  TestLines.append("傳統喪禮儀式中每七天為一旬。一、三、五、七旬為大旬，必須請道士做法會，稱作「做七」(tsò-tshit)或是「做旬」(tsò-sûn)，到七旬結束才算功德圓滿。")
  ExpectedLines.append("傳統喪禮儀式中每七天為一旬。一、三、五、七旬為大旬，必須請道士做法會，稱作「做七」(tso3-tshit4)或是「做旬」(tso3-sun5)，到七旬結束才算功德圓滿。")
  TestLines.append("￹㧻破￺tok-phuà￻敲破")
  ExpectedLines.append("￹㧻破￺tok4-phua3￻敲破")
  TestLines.append("我。第一人稱單數代名詞。多為女性自稱，歌唱中常只唸gún的音，而不唸guán。")
  ExpectedLines.append("我。第一人稱單數代名詞。多為女性自稱，歌唱中常只唸gun2的音，而不唸guan2。")
  TestLines.append("全部的、整個的。")
  ExpectedLines.append("全部的、整個的。")
  TestLines.append("kah it piánn ting")
  ExpectedLines.append("kah4 it4 piann2 ting1")  
  TestLines.append("piánn")
  ExpectedLines.append("piann2")  
  PassCount = 0
  TestCount = 0
  for TestLine in TestLines:
    # Note: below line assumes above for loops in order,
    #   seems to work but likely there is a more robust way of doing this.
    ExpectedLine = ExpectedLines[TestCount] 
    TestCount += 1
    print( "{0}: ".format(TestCount) + TestLine )
    ResultLine = LineDiacriticToNumeric(TestLine)
    print( ResultLine )
    if ( ResultLine == ExpectedLine ):
      PassCount += 1
    else:
      print( "Test {0} failed (unexpected result).".format(TestCount) )
  print( "{0} out of {1} tests passed.".format(PassCount, TestCount) )
# TestDiacriticToNumeric()