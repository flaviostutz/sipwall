#!/bin/sh

IP=$1

COUNTRIES=$(whois $IP | grep ountry | perl -n -e'/ountry:.*(..)/ && print "$1 "')
if [ "$COUNTRIES" == "" ]; then
  COUNTRIES=$(whois -a $IP | grep ountry | perl -n -e'/ountry:.*(..)/ && print "$1 "')
fi
# COUNTRY=$(whois -a $1 | grep -m1 ountry | perl -n -e'/ountry:.*(..)/ && print $1')
# COUNTRY=$(curl -s http://ipinfo.io/$1 | perl -n -e'/ountry":.*"(..)"/ && print $1')

for COUNTRY in $COUNTRIES
do
  # echo "IP $IP is from $COUNTRY"

  for ALLOWED_COUNTRY in $ALLOWED_COUNTRIES
  do
    if [ "$COUNTRY" == "$ALLOWED_COUNTRY" ]; then
      if [ "$LOG_LEVEL" == "DEBUG" ]; then
        echo "IP $IP ALLOWED - COUNTRY $COUNTRY"
      fi
      return 0
    fi
  done

done

if [ "$LOG_LEVEL" == "DEBUG" ]; then
  echo "IP $1 NOT ALLOWED - COUNTRY $COUNTRY"
fi
return 1

