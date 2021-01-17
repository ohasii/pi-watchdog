#!/bin/bash
###
# E-ZAK TECHNOLOGY
#
# Service...: Router Watchdog
# Author....: Issac Nolis Ohasi
# Release...: 2021.01
###

###
# Copyright (C) 2021 Issac Nolis Ohasi
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
###

###
# GLOBAL SETTINGS
###
RESET_TIME=15
GPIO_PORTS=(15 16 1 4 5 6 10 11)
DEVICE_NAME=("ISP-1: Claro" "ISP-1: ETH > SFP" "ISP-1: SFP > ETH" "Gateway-1F" "Switch-1F" "Audio-1: SFP > ETH" "Audio-2: SFP > ETH" )

###
# CONSTANTS
###
FONT_BOLD=$(tput bold)

FONT_COLOR_RED=$(tput setaf 1)
FONT_COLOR_GREEN=$(tput setaf 2)
FONT_COLOR_YELLOW=$(tput setaf 3)
FONT_COLOR_DARKBLUE=$(tput setaf 4)
FONT_COLOR_PURPLE=$(tput setaf 5)
FONT_COLOR_BLUE=$(tput setaf 6)
FONT_COLOR_WHITE=$(tput setaf 7)

FONT_STANDARD=$(tput sgr 0)

###
# FUNCTION display_header
###
display_header()
{
  echo -e "$FONT_COLOR_YELLOW$FONT_BOLD"
  echo -e "E-ZAK Router Watchdog"
  echo -e "Copyright (C) 2021 Issac Nolis Ohasi"
  echo -e "$FONT_STANDARD"
}

###
# FUNCTION display_help
###
display_help()
{
  echo "Usage: `basename $0` [option...] [args...] " >&2
  echo
  echo "   -i, --init-relay           Initialize Raspberry PI GPIO for relays"
  echo "   -r, --reset-device [DevID] Perform hard reset on device"
  echo "   -h, --help                 Show help options"
  echo
  exit 1
}

###
# FUNCTION init_relays
###
init_relays()
{
  i=0
  echo -e "$FONT_COLOR_YELLOW$FONT_BOLD"
  echo -e "Initializing relays..."
  echo
  for gpio_id in "${GPIO_PORTS[@]}"
  do
    device="${DEVICE_NAME[i]}"
    printf "%s%s %s %s %s" "$FONT_COLOR_YELLOW$FONT_BOLD" "Relay Port [" "$FONT_COLOR_PURPLE" "$i" "$FONT_COLOR_YELLOW ] $FONT_COLOR_BLUE" "$device"
    printf "\n"
    gpio mode $gpio_id  out
    gpio write $gpio_id 1
    sleep 10
    let "i += 1"
  done
  echo -e "$FONT_STANDARD"
}

###
# FUNCTION reset_device
###
reset_device()
{
  relays=${#GPIO_PORTS[@]}
  let "relays -= 1"
  device_id=$1

  if [ $device_id -gt $relays ]
  then
    printf "%s\n" "Invalid device id"
    exit 1
  fi

  gpio_port="${GPIO_PORTS[device_id]}"
  device="${DEVICE_NAME[device_id]}"
  gpio write "$gpio_port" 0

  printf "%s%s\t\t" "$FONT_BOLD$FONT_COLOR_YELLOW" "Restarting device $FONT_COLOR_BLUE$device..."

  sleep "$RESET_TIME"
  gpio write "$gpio_port" 1

  printf "%s\n" "$FONT_COLOR_YELLOW[$FONT_COLOR_GREEN SUCCESS $FONT_COLOR_YELLOW]$FONT_WHITE"
}

###
# FUNCTION main
###
display_header
case "$1" in
  -i | --init-relay)
    init_relays
    exit 0
    ;;
  -r | --reset-device)
    reset_device $2
    exit 0
    ;;
  -h | --help)
    display_help
    exit 0
    ;;
  -*)
    echo "Error: Unknown option: $1" >&2
    display_help
    exit 1
    ;;
  *)  # No more options
    if [ "$#" -eq 0 ]
    then
      display_help
      exit 1
    fi
    break
    ;;
esac



