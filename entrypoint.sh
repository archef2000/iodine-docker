#!/bin/bash

get_dns_type() {
  local dns_type="$1"
  if [[ -z "${dns_type}" ]]; then
    return
  fi
  local valid_options=("PRIVATE" "NULL" "TXT" "SRV" "MX" "CNAME" "A")
  
  for valid_option in "${valid_options[@]}"; do
    if [[ "${dns_type^^}" == *"${valid_option}"* ]]; then
      echo "-T ${valid_option} "
      return
    fi
  done
  return
}

arguments=("-f")

if [[ $@ != server* && $@ != client* ]]; then
  bash -c "$@"
  exit 0
elif [[ $@ == server* ]]; then
  case "${LOG_LEVEL%%[^0-9]*}" in
    2)
      echo "::: LOG LEVEL extreme debug"
      arguments+=("-DD")
      ;;
    1)
      echo "::: LOG LEVEL debug"
      arguments+=("-D")
      ;;
    *)
      echo "::: LOG LEVEL default"
      ;;
  esac
  if [ -z "${FORWARD_DEST}" ]; then
    echo "::: Forward destination not set, skipping"
  else
    if [ $(cat "/proc/sys/net/ipv4/ip_forward") -ne 1 ]; then
      echo "::: Please set sysctl net.ipv4.ip_forward to 1"
      exit 1
    fi
    iptables -t nat -A PREROUTING -p udp --dport 53530 -j DNAT --to-destination "${FORWARD_DEST}"
    echo "::: Forward destination set to ${FORWARD_DEST}"
    arguments+=("-b 53530")
  fi
fi

if [ -z "${PASSWORD}" ]; then
  echo "::: PASSWORD not set"
  exit 1
else
  arguments+=("-P ${PASSWORD}")
fi

if [ ! -z "${DEV_TUNNEL}" ]; then
  echo "::: Custom tunnel device set to '${DEV_TUNNEL}'"
  arguments+=("-d ${DEV_TUNNEL}")
fi

MTU="${MTU%%[^0-9]*}"
if [ -z "${MTU}" ]; then
  echo "::: MTU is autoprobed"
else
  echo "::: MTU is set to ${MTU}"
  arguments+=("-m ${MTU}")
fi

if [[ $@ == server* ]]; then
  if [ -z "${NETWORK}" ]; then
    echo "::: NETWORK not set"
    exit 1
  else
    echo "::: NETWORK set to ${NETWORK}"
    arguments+=("${NETWORK}")
  fi

  if [ -z "${DOMAIN}" ]; then
    echo "::: DOMAIN not set"
    exit 1
  else
    echo "::: DOMAIN set to ${DOMAIN}"
    arguments+=("${DOMAIN}")
  fi

  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  iptables -A FORWARD -i eth0 -o dns0 -m state --state RELATED,ESTABLISHED -j ACCEPT
  iptables -A FORWARD -i dns0 -o eth0 -j ACCEPT

  echo "${arguments[@]}"
  iodined -c "${arguments[@]}"
else
  arguments+=($(get_dns_type "${DNS_TYPE}"))
  if [ ! -z "${MAX_INTERVAL}" ]; then
    arguments+=("-I${MAX_INTERVAL%%[^0-9]*}")
    echo "::: Max interval between request set to ${MAX_INTERVAL%%[^0-9]*}"
  fi
  if [ "${LAZY_MODE,,}" == "true" ]; then
    arguments+=("-L1")
    echo "::: Lazy mode activated"
  else
    arguments+=("-L0")
    echo "::: Lazy mode deactivated"
  fi
  if [ "${FORCE_DNS_TUNNEL,,}" == "true" ]; then
    arguments+=("-r")
    echo "::: Skipping RAW mode"
  fi
  if [ ! -z "${HOSTNAME_SIZE,,}" ]; then
    arguments+=("-M ${HOSTNAME_SIZE,,}")
    echo "::: Upstream hostname size set to '${HOSTNAME_SIZE,,}'"
  else
    echo "::: Default upstream hostname size"
  fi
  if [ ! -z "${DNS_SERVER}" ]; then
    arguments+=("${DNS_SERVER}")
  fi
  if [ -z "${DOMAIN}" ]; then
    echo "::: DOMAIN not set"
    exit 1
  else
    echo "::: DOMAIN set to ${DOMAIN}"
    arguments+=("${DOMAIN}")
  fi
  
  echo "${arguments[@]}"
  iodine "${arguments[@]}"
fi
