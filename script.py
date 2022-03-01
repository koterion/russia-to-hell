import requests
import os

def myping(host):
    response = os.system("ping -c 1 " + host)

    if response == 0:
        return True
    else:
        return False

url = 'https://raw.githubusercontent.com/koterion/russia-to-hell/36c6f4013c3be99743e948ee8ae5eec3778fa343/resources.txt'
r = requests.get(url, allow_redirects=True)

#open('resources.txt', 'wb').write(r.content)

headers = {
    'Accept': 'application/json'
}
base_url ='https://check-host.net/check-ping'
live_urls = []

content = r.content.decode('utf-8').split("\n")
for line in content:
    line = line.replace('https://', '')
    line = line.replace('http://', '')
    if line:
        if myping(line):
            live_urls.append(line)

with open('activeHosts.txt', 'w') as f:
    for url in live_urls:
        f.write(url+'\n')
