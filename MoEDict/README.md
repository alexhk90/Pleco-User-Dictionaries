# MoEDict Pleco User Dictionary Conversion
Taiwan Ministry of Eduction Revised Chinese Dictionary (教育部重編國語辭典修訂本).

The source files in this directory relate to the conversion of the Taiwan **MoE** Revised Chinese **Dict**ionary (henceforth MoEDict) to Pleco user dictionary format.

Original discussion thread:
* [The MoE dictionary is now open source (PlecoForums)](http://www.plecoforums.com/threads/the-moe-dictionary-is-now-open-source.3606/)

Latest download links (MoEDict-05), output from source files:
* Pleco flashcards (.txt) (165,814 entries):
  * [MoEDict-05-cards.txt (MediaFire)](http://www.mediafire.com/download/3j8un86dri4stjv/MoEDict-05-cards.txt)
  * [MoEDict-05-cards.txt.7z (DropBox)](https://www.dropbox.com/s/3g8ewbvtdwzwdh9/MoEDict-05-cards.txt.7z)
* Pleco user dictionary file (.pqb) (165,814 entries):
  * [MoEDict-05.pqb.7z (MediaFire)](http://www.mediafire.com/download/b7b7hx91qet7b6q/MoEDict-05.pqb.7z)
  * [MoEDict-05.pqb.7z (DropBox)](https://www.dropbox.com/s/s5amxb0cvnz5kj2/MoEDict-05.pqb.7z)

Current Pleco user dictionary conversion source files:
* [SQL script](MoEDict-Pleco-Conversion.sql) (includes conversion notes as comments)
* [Conversion notes](MoEDict-Pleco-Conversion) (somewhat deprecated as superseded by SQL script)

Data sources:
* [Official web interface](http://dict.revised.moe.edu.tw/) (original source data)
* [Output data in HTML, JSON and SQLite formats](http://kcwu.csie.org/~kcwu/moedict/) (HTML downloaded from official web interface and converted)
* [General information](https://g0v.hackpad.com/3du.tw-ZNwaun62BP4) (g0v information on MoE dictionaries)
* [Data conversion process](https://github.com/g0v/moedict-process/) (on converting MoE dictionary data to more user-friendly formats)
* [Output data](https://github.com/g0v/moedict-data/) (includes updated JSON from data conversion process)
* [Unicode conversion](https://github.com/g0v/moedict-epub/) (for rare characters not encoded as Unicode in source data)

## Headwords Traditional to Simplified Conversion
The source data is all in traditional characters, but for better intercompatibility in merged searches with other dictionaries, a simple conversion of the headwords has been done using the associated Pinyin.

Latest download links (MoEDict-05-Simp03), output from source files:
* Pleco flashcards (.txt) (165,814 entries):
  * [MoEDict-05-Simp03-cards.txt (MediaFire)](http://www.mediafire.com/download/2orvm92ig6118u1/MoEDict-05-Simp03-cards.txt)
  * [MoEDict-05-Simp03-cards.txt.7z (DropBox)](https://www.dropbox.com/s/avy920um3wuijpl/MoEDict-05-Simp03-cards.txt.7z)
* Pleco user dictionary file (.pqb) (165,814 entries):
  * [MoEDict-05-Simp03.pqb.7z (MediaFire)](http://www.mediafire.com/download/642ykctfv9a4300/MoEDict-05-Simp03.pqb.7z)
  * [MoEDict-05-Simp03.pqb.7z (DropBox)](https://www.dropbox.com/s/mby9xmnix3vdzcr/MoEDict-05-Simp03.pqb.7z)

Current simplified headwords conversion source files:
* [Bash script](MoEDict-Pleco-Conversion-Simplified.sh) (run this on the output of the MoEDict conversion process above, with the conversion tables from the [Traditional to Simplified conversion](../Simplified) directory)
* [Conversion notes](MoEDict-Pleco-Conversion-Simplified) (somewhat deprecated as superseded by Bash script)

See [Traditional to Simplified conversion](../Simplified) directory for more information.
