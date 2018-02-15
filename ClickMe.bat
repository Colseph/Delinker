@echo off
setlocal enabledelayedexpansion
::TODO fix problems with !

::~file extracts ordered chapters from mkv then remuxes
::~main ep without them and splits it where the chapters say
::~then remuxes everything back together to make a big dongo fam

::~config~
set mkvExtract="F:\Programs\servUtils\Fix MKV\mkvtoolnix-64bit-14.0.0\mkvtoolnix\mkvextract.exe"
set mkvMerge="F:\Programs\servUtils\Fix MKV\mkvtoolnix-64bit-14.0.0\mkvtoolnix\mkvMerge.exe"



:LINK START
set /p inputPath="Enter Full File Path(NO QUOTES OR "^^^!" IN PATH\FILENAME): "
set homePath=%cd%
%inputPath:~0,2%
cd "%inputPath%"
::cerates json of every files info along with inex for python to search for suid
echo Creating Json files
if EXIST "%homePath%\jsonIndex.txt" (
del "%homePath%\jsonIndex.txt"
)
for /f "TOKENS=*" %%i in ('dir /B *.mkv') do (
if NOT EXIST "%%~fi" (
echo ERROR CANNOT FIND FILE: %%~fi 
echo CHECK FILE NAME FOR ^^^! SYMBOL OR FOREIGN LANGUAGE^(UNICODE STUFF^)
echo IF A SYMBOL DOESNT APPEAR IN THE NAME ABOVE, THEN THIS PROGRAM CANT SEE IT
echo ^(so just remove from filename and your good to go^)
pause
goto eof
)
%mkvMerge%  --identification-format json --identify "%%~nxi" > "%homePath%\%%~nxi.json"
echo %%~nxi.json >> "%homePath%\jsonIndex.txt"
)
for /f "TOKENS=*" %%i in ('dir /B *.mkv') do (
echo unlinking %%~nxi
::sends file info to xml for python to parse
echo extracting chapters
%mkvExtract% chapters "%%~nxi" > "%homePath%\tempChapters.xml"
::gets values form python
%homePath:~0,2%
cd "%homePath%"
py Delinker.py
call pyReturn.bat rem chapNum, splitTimecodes

::splits episode takes away chapters
%mkvMerge% -o "part.mkv" --split timecodes:!timeCodes! --no-chapters "%%~fi"

::merges parts with oped and new chapters
%mkvMerge% -o "%%~fi-NEW.mkv" --chapters "newxml.xml" --append-mode file !parts!
::deletes mkv and xml and pyReturn for clean start per file
del *.xml
del pyReturn.bat
del *.mkv
%inputPath:~0,2%
cd "%inputPath%"
)
%homePath:~0,2%
cd "%homePath%"
::deletes excess files and cleans up the mess..
del *.json
del *.txt
:eof

pause
