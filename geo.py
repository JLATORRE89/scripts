import geocoder
import os

os.chdir("/home/dev/ProductFinder/backend/")
with open("access.log") as f:
    lineList = f.readlines()
    NetItem = []
    IpList = []
    for item in lineList:
        NetItem = item.split("\n")
        for i in NetItem:
            split = i.split(" ")
            if split[0] not in IpList:
                IpList.append(split[0])

for item in IpList:
    g = geocoder.ip(item)
    print(item, g.latlng)
