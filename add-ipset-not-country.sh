#!/bin/sh

IP=$1
IPSETNAME=$2

/authorized-country.sh $IP
AUTHORIZED=$?

if [ "$AUTHORIZED" == "1" ]; then
  echo "Adding $IP to blacklist (country)"
  ipset --test $IPSETNAME <ip> || ipset --add $IPSETNAME $IP
else
  echo "IP $IP is from an authorized country. Won't blacklist it."
fi

