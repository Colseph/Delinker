#!/usr/bin/env bash

#~unfortunately bash has a hard time with 'ls'ing dirs(with spaces) stored in variable
#~luckily arrays are the answer

#~Config~
mkvExtract="path to mkvExtract"
mkvMerge="path to mkvMerge"
#~end config~


#~Functions
#~---------

getFileList() { #~gets file list in array
	#~sets ifs to get full file name and path(even if it has spaces)
	IFSOLD="$IFS"
	IFS=""
	fileList=$(ls $inputPath/*.mkv)
	echo $fileList
	echo -----
	IFS=$'\n'
	fileArray=($fileList)
	IFS=$IFSOLD
	echo "${fileArray[@]}"
	echo -----
}

makeJson() { #~extracts info from files in json format
	#~creates json index file for python
	echo "Creating Json Files"
	for mkvFile in "${fileArray[@]}"; do
		echo $mkvMerge --identification-format json --identify "$mkvFile" > "./$(basename "$mkvFile").json"
		echo "$(basename "$mkvFile").json" >> "./jsonIndex.txt"
	done
}

getInfo() { #~gets information form Delinker.py
	for mkvFile in "${fileArray[@]}"; do
		echo "Extracting Chapters for '$(basename "$mkvFile")'"
		#~sends file info/chapters to xml for python to parse
		echo $mkvExtract chapters $mkvFile > "./tempChapters.xml"
		#~runs Python and gets vars
		echo ./Delinker.py
		#~gets vars from python(reads text file into array)
		#~for reference the order of the array is:
		#~a bunch of outsideChap# vars not sure if relevent yet
		#~partNum timeCodes
		echo 'pythonVars=('cat ./pyReturn.txt')'
		remux
	done
}

remux() { #~Remuxes mkv file
	#~splits and removes chapters
	echo $mkvMerge -o "./part.mkv" --split timecodes:$timecodes --no-chapters $mkvFile
	#~inserts parts and merges together. adds chatpers back in
	echo $mkvMerge -o "$mkvFile-NEW.mkv" --chapters "newxml.xml" --append-mode file $parts
	#~cleans up for next file
	rm -rf *.xml
	echo rm -rf pyReturn.sh
	rm -rf *.mkv
}

#~リンクスタート！
#~---------------

cat<<EOF
Remember - leave the end '/' off of your path
example: /etc/files/Videos/randomShow
EOF
read -p "Enter FULL Path to Files(no '~/' or '\$HOME'): " inputPath

#~calls Functions-
getFileList
makeJson
getInfo

#~cleans up the mess.
rm -rf *.json
rm -rf *.txt
echo Done!
read -s -N 1 -p "Press Any Key To Continue..." tempVar

