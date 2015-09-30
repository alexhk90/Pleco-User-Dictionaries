# MoE Minnan Pleco User Dictionary Conversion
Taiwan Ministry of Education Dictionary of Frequently-Used Taiwan Minnan (臺灣閩南語常用詞辭典).

The source files in this directory relate to the conversion of the Taiwan **MoE** Dictionary of Frequently-Used Taiwan **Minnan** (henceforth MoE-Minnan) to Pleco user dictionary format.

Original discussion thread:
* [MoE Minnan and Hakka dictionaries (PlecoForums)](http://www.plecoforums.com/threads/moe-minnan-and-hakka-dictionaries.4938/)

Latest download links (MoE-Minnan-v04), output from source files:
* Pleco flashcards (.txt) (14,005 entries)
  * [MoE-Minnan-flashcards-v04.txt.7z](https://www.dropbox.com/s/96oalq272vw525c/MoE-Minnan-flashcards-v04.txt.7z?dl=0)

Current Pleco user dictionary conversion source files:
* [Python script](MoE-Minnan-Pleco-Conversion.py) (includes conversion notes as comments)
* [Conversion notes](MoE-Minnan-Pleco-Conversion.txt) (higher level notes)

Data sources:
* [Official web interface](http://twblg.dict.edu.tw/) (original source data)
* [Converted data](https://github.com/g0v/moedict-data-twblg/) (includes JSON format)
* [Official news announcement](http://english.moe.gov.tw/ct.asp?xItem=14785&ctNode=11446&mp=1)

## Numeric Tone Conversion for Romanisation
The source data has Romanisations with diacritic tone marks, but these do not always display well so instead they are converted to numeric tones.

Latest download links (MoE-Minnan-v04-numeric), output from source files:
* Pleco flashcards (.txt) (14,005 entries)
  * [MoE-Minnan-flashcards-v04-numeric.txt.7z](https://www.dropbox.com/s/yyqkg343zuhzjna/MoE-Minnan-flashcards-v04-numeric.txt.7z?dl=0)

* [Python helper module](TWRomanisation.py) (used by Python script when NUMERIC_TONES constant set to True)
* [JSON mapping data](Romanisation-tones.json) (used by Python helper module)
