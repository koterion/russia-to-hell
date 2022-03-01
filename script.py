import os

def myping(host):
    response = os.system("ping -c 1 " + host)

    if response == 0:
        return True
    else:
        return False

#open('resources.txt', 'wb').write(r.content)

live_urls = []

with open('resources.txt', 'r') as targets:
    for line in targets.readlines():
        line = line.replace('\n', '')
        line = line.replace('https://', '')
        line = line.replace('http://', '')
        if line:
            if myping(line):
                live_urls.append(line)

with open('activeHosts.txt', 'w') as f:
    for url in live_urls:
        f.write(url+'\n')
