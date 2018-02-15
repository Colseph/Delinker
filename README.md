# Delinker Linux
Python/bash re-attaches video files that use segment linking or "ordered chapters"

* incomplete atm i dont have linux installed so i cant test and finish
* as of now its just guesswork, hoping things will function properly

### Dependencies:
* --this *assumes* that mkvtoolnix works the same as on windows
    -as said above, dont currently have linux installed
* [MkvToolnix(mkvExtract & mkvMerge)](https://mkvtoolnix.download/)
* [Python3.6](https://www.python.org/downloads/) bs4, json, sys

### Getting started:
1. get dependencies 
   - download and extract mkvtools(doesn't really matter where you put them)
   - install python then install modules w/ pip
2. edit config in ClickMe.sh
   - set variables to point to mkvExtract and mkvMerge
3. run ClickMe.sh, follow instructions and Fix your files.
