from lxml import html
import requests


url = 'https://www.walmart.com/search/?page=1&ps=40&query=toilet+paper'
page = requests.get(url)
tree = html.fromstring(page.content)


# //*[@id="searchProductResult"]/ul/li[1]/div/div[2]/div[5]/div
results = tree.xpath('//mark')

print('Results: ', results)
