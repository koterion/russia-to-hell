import requests
import os
def myping(host):
    response = os.system("ping -c 1 " + host)

    if response == 0:
        return True
    else:
        return False

live_urls = []
with open('resources.txt') as f:
    lines = f.readlines()
    for line in lines:
        line = line.replace("\n", '')
        line = line.replace('https://', '')
        line = line.replace('http://', '')
        if line:
            if myping(line):
                live_urls.append(line)

with open('activeHosts.txt', 'w') as f:
    for url in live_urls:
        f.write(url+'\n')
