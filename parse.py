from bs4 import BeautifulSoup
import json
import requests

# Search term should collect user input from HTML form.
SearchTerm = 'Angel Soft'
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
jsonContent = json.loads(hits)
print(jsonContent)
#for span in hits:
#    if span.__contains__(SearchTerm) :
#        if span.__contains__("OUT_OF_STOCK") :
#            print('Found out of stock item.')
# "highlightedTitleTerms":["Angel","Soft"]
# "inventory":{"displayFlags":["OUT_OF_STOCK"],"availableOnline":false}

