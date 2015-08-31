# MoEDict Pleco User Dictionary Conversion
Taiwan Ministry of Eduction Revised Chinese Dictionary (教育部重編國語辭典修訂本).

The source files in this directory relate to the conversion of the Taiwan **MoE** Revised Chinese **Dict**ionary (henceforth MoEDict) to Pleco user dictionary format.

Original discussion thread:
* [The MoE dictionary is now open source (PlecoForums)](http://www.plecoforums.com/threads/the-moe-dictionary-is-now-open-source.3606/)

Current Pleco user dictionary conversion source files:
* [SQL script](MoEDict-Pleco-Conversion.sql) (includes conversion notes as comments)
* [Conversion notes](MoEDict-Pleco-Conversion) (somewhat deprecated as superseded by SQL script)

Latest download links (MoEDict-05), output from source files:
* Pleco flashcards (.txt) (165,814 entries):
  * [MoEDict-05-cards.txt (MediaFire)](http://www.mediafire.com/download/3j8un86dri4stjv/MoEDict-05-cards.txt)
  * [MoEDict-05-cards.txt.7z (DropBox)](https://www.dropbox.com/s/3g8ewbvtdwzwdh9/MoEDict-05-cards.txt.7z)
* Pleco user dictionary file (.pqb) (165,814 entries):
  * [MoEDict-05.pqb.7z (MediaFire)](http://www.mediafire.com/download/b7b7hx91qet7b6q/MoEDict-05.pqb.7z)
  * [MoEDict-05.pqb.7z (DropBox)](https://www.dropbox.com/s/s5amxb0cvnz5kj2/MoEDict-05.pqb.7z)

## Headwords Simplified to Traditional Conversion
The source data is all in traditional characters, but for better intercompatibility in merged searches with other dictionaries, a simple conversion of the headwords has been done using the associated Pinyin.

Current simplified headwords conversion source files:
* [Bash script](MoEDict-Pleco-Conversion-Simplified.sh)
* [Conversion notes](MoEDict-Pleco-Conversion-Simplified)

Latest download links (MoEDict-05-Simp03), output from source files:
* Pleco flashcards (.txt) (165,814 entries):
  * [MoEDict-05-Simp03-cards.txt (MediaFire)](http://www.mediafire.com/download/2orvm92ig6118u1/MoEDict-05-Simp03-cards.txt)
  * [MoEDict-05-Simp03-cards.txt.7z (DropBox)](https://www.dropbox.com/s/avy920um3wuijpl/MoEDict-05-Simp03-cards.txt.7z)
* Pleco user dictionary file (.pqb) (165,814 entries):
  * [MoEDict-05-Simp03.pqb.7z (MediaFire)](http://www.mediafire.com/download/642ykctfv9a4300/MoEDict-05-Simp03.pqb.7z)
  * [MoEDict-05-Simp03.pqb.7z (DropBox)](https://www.dropbox.com/s/mby9xmnix3vdzcr/MoEDict-05-Simp03.pqb.7z)
