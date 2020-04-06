#!/bin/sh

IP=$1
IPSETNAME=$2

# echo "CHECKING IF IP $IP WILL BE BANNED"

/authorized-country.sh $IP
AUTHORIZED=$?

if [ "$AUTHORIZED" == "1" ]; then
  echo "Adding $IP to blacklist (country)"
  ipset --add $IPSETNAME $IP
else
  echo "IP $IP is from an authorized country. Won't blacklist it. (country)"
fi

