#~File: DeLinker
#~gets suid and timestamps for linked ed and op from episode.
#~splits epa at timestamps without chaps, then muxes everything together.
#~Uses Python 3.6

#~import god files
from bs4 import BeautifulSoup
import json
import sys


#~Config

#~Define Functions

def addHMS(t1,t2):
    print("getting time code")
    hms = []
    #~gets seocnds.millisecs
    print(str(t1) + "\n" + str(t2))
    secs = float(t1[2]) + float(t2[2])
    #print(secs)
    actualSecs = '{0:.9f}'.format(float(secs%60))
    #print(actualSecs)
    #~gets minutes
    minutes = int(secs/60) + int(t1[1]) + int(t2[1])
    #print(minutes)
    actualMin = '{0:0>2}'.format(int(minutes%60))
    #print(actualMin)
    #~gets hours
    hours = '{0:0>2}'.format(int(minutes/60) + int(t1[0]) + int(t2[0]))
    #print(hours)
    hms = str(hours) + ":" + str(actualMin) + ":" + str(actualSecs)
    print("timeCode: " + str(hms))
    return hms
    

def findBySuid(suid):
    #~reads all json files to find the op with correct suid
    with open('jsonIndex.txt', mode='r', encoding='utf-8') as jIndex:
        print("searching for file with suid: " + str(suid))
        for line in jIndex:
            lineEntry = line
            lineEntry = lineEntry.replace("\r","")
            lineEntry = lineEntry.replace("\n","")
            #print("finding suid for " + str(lineEntry))
            with open(lineEntry, mode='r', encoding='utf-8') as jFile:
                wjData = json.load(jFile)
                #print("suid " + str(wjData['container']['properties']['segment_uid']) + "\n")
                if str(wjData['container']['properties']['segment_uid']) == str(suid):
                    print("Found File with matching suid:\n" + str(lineEntry).replace('.json',''))
                    fileName = str(lineEntry).replace('.json','')
                    break
    return fileName


def ReviseXML(TC):
    print("revising XML File")
    with open('tempChapters.xml',mode='r', encoding='utf-8') as xml, open('newxml.xml', mode='w', encoding='utf-8') as newXml:
        chapter = 1
        for line in xml:
            if '/chapteratom' in line.lower():
                chapter += 1
            if 'chaptersegmentuid' in line.lower():
                print("removing suid")
            elif 'chaptertimestart' in line.lower():
                newXml.write('    <ChapterTimeStart>' + str(TC['chapter' + str(chapter -1)]) + '</ChapterTimeStart>\n')
            elif 'chaptertimeend' in line.lower():
                newXml.write('    <ChapterTimeEnd>' + str(TC['chapter' + str(chapter)]) + '</ChapterTimeEnd>\n')
            else:
                newXml.write(line)
    

def parseChapters():
    with open('tempChapters.xml', mode='r', encoding='utf-8') as chaps, open('pyReturn.bat', mode='w', encoding='utf-8') as pyReturn:
        soup = BeautifulSoup(chaps, 'html.parser')
        timecode = '00:00:00.000000000'
        newXMLTCO = '00:00:00.000000000'
        timeCodes = ''
        parts = ''
        partNum = 0
        partTrigger = ''
        chapNum = 1
        outSideChaps = 0
        newXMLTCDic = {'chapter0': '00:00:00.000000000'}
        for chapter in soup.findAll('chapteratom'):
            print("\nparsing chapter " + str(chapNum))
            outie = chapter.chaptersegmentuid
            if str(outie).lower() == 'none':
                #~if suid is in chapter(means its the op or ed)
                print("no suid here...")
                timecode = str(chapter.find('chaptertimeend').text)
                newXMLTC = addHMS(newXMLTCO.split(':'),timecode.split(':'))
                newXMLTCDic['chapter' + str(chapNum)] = newXMLTC
                if not partTrigger == 'in':
                    partNum += 1
                    parts += 'part-' + str('{0:0>3}'.format(partNum)) + '.mkv +'
                    partTrigger = 'in'
            else:
                print("found suid")
                outSideChaps += 1
                newXMLTCO = addHMS(newXMLTCO.split(':'),str(chapter.find('chaptertimeend').text).split(':'))
                newXMLTCDic['chapter' + str(chapNum)] = addHMS(newXMLTC.split(':'),str(chapter.find('chaptertimeend').text).split(':'))
                chapterFile = findBySuid(chapter.find('chaptersegmentuid').text)
                timeCodes +=str(timecode) + ','
                pyReturn.write('set outsideChap' + str(outSideChaps) + '=' + str(chapterFile) + '\n')
                if not partTrigger == 'out':
                    parts += '"%inputPath%\\' + str(chapterFile) + '" +'
                    partTrigger = 'out'
            chapNum += 1
        timeCodes = timeCodes[:-1]
        print(newXMLTCDic)
        print(timeCodes)
        pyReturn.write('set partNum=' + str(partNum) + '\nset timeCodes=' + str(timeCodes[:-1]) + '\nset parts=' + str(parts[:-1]) + '\n')
        ReviseXML(newXMLTCDic)


#~PROGRAM STARTO
print("ohayou Python-sama")
parseChapters()
print("ja ne")
