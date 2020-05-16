from bs4 import BeautifulSoup
import urllib3
import requests
import csv

# Input from user or service
SearchTerm = input("Enter Product to search for: ")
# Format and query URL with user input
SearchSplit = SearchTerm.split(' ')
SearchMark = SearchTerm.replace(' ', '+')
url = 'https://www.walmart.com/search/?page=1&ps=40&query=' + SearchMark
website = requests.get(url).text
soup = BeautifulSoup(website, 'lxml')

# process the status of a single product.
def ProductStatus( itemUrl ):
    productWebsite = requests.get(itemUrl).text
    productSoup = BeautifulSoup(productWebsite, 'lxml')
    itemStatus = productSoup.find(class_='prod-fulfillment-messaging-text')
    return itemStatus.text

# Write CSV file for end user consumption.
with open('walmart.csv', 'w', newline='') as csv_file:
    csv_writer = csv.writer(csv_file)
    csv_writer.writerow(['item name', 'item url', 'status'])
    for item in soup.find_all(class_='product-title-link line-clamp line-clamp-2 truncate-title'):
        if item.text.__contains__(SearchTerm) :
            text = item.text.replace(",", '')
            itemUrl = 'https://www.walmart.com' + item.get('href')
            itemStatus = ProductStatus(itemUrl)
            csv_writer.writerow([text, itemUrl, itemStatus])

