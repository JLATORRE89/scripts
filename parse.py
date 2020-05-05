from bs4 import BeautifulSoup
import json
import requests

SearchTerm = 'Angel Soft'
SearchSplit = SearchTerm.split(' ')
SearchMark = SearchTerm.replace(' ', '+')
url = 'https://www.walmart.com/search/?page=1&ps=40&query=' + SearchMark
page = requests.get(url)

soup = BeautifulSoup(page.content, 'html.parser')
# search for json content <script id="searchContent" type="application/json">
hits = soup.find(id="searchContent")
# strip out all hits, load json, parse results.
hits = str(hits)
hits = hits.strip('<script id="searchContent" type="application/json">')
hits = hits.strip('</script>')
jsonData = {}
jsonData = json.loads(hits)
# https://stackabuse.com/reading-and-writing-json-to-a-file-in-python/
jsonData = json.dumps(jsonData, sort_keys=True, separators=(',', ':'))
jsonData = bytes(jsonData, "utf-8").decode("unicode_escape")

with open('data.json', 'w') as outfile:
    json.dump(jsonData, outfile)

#for item in jsonData:
#    if item.__contains__("\" + SeachSplit[0] + \" ") :
#        print(item)


#for item in jsonData[3]:
#    print('Name: ' + item[0])


#with open('data.json') as json_file:
    #data = json.load(json_file)

    #for p in data[]:
    #    print('Title: ' + p[0])
#for span in hits:
#    if span.__contains__(SearchTerm) :
#        if span.__contains__("OUT_OF_STOCK") :
#            print('Found out of stock item.')
# "highlightedTitleTerms":["Angel","Soft"]
# "inventory":{"displayFlags":["OUT_OF_STOCK"],"availableOnline":false}


