#!/bin/sh

# COUNTRY=$(whois $1 | grep -m1 Country | perl -n -e'/Country:.*(..)/ && print $1')
COUNTRY=$(curl -s http://ipinfo.io/$1 | perl -n -e'/ountry":.*"(..)"/ && print $1')
echo "IP $1 is from $COUNTRY"

for ALLOWED_COUNTRY in $ALLOWED_COUNTRIES
do
  if [ "$COUNTRY" == "$ALLOWED_COUNTRY" ]; then
    echo "IP ALLOWED FROM COUNTRY $COUNTRY"
    exit 1
  fi
done

echo "IP NOT ALLOWED FROM COUNTRY $COUNTRY"
exit 0

