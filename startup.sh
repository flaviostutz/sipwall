#!/bin/sh

if [ "$TCPDUMP_INTERFACE" == "" ]; then
  echo "ENV TCPDUMP_INTERFACE is required"
  exit 1
fi


#Tail log to stdout
tail -F /var/log/fail2ban.log&


#Initial preparations
if [ ! -f /init ]; then
  echo "Preparing config files according to ENVs..."
  # sed -i 's|logtarget = /var/log/fail2ban.log|logtarget = STDOUT|g' /etc/fail2ban/fail2ban.conf
  sed -i "s|loglevel = INFO|loglevel = $LOG_LEVEL|g" /etc/fail2ban/fail2ban.conf

  if [ "$BAN_DENIED_TRIALS" == "true" ]; then
    envsubst < /sipwall-denied.conf.tmpl > /etc/fail2ban/jail.d/sipwall-denied.conf
  fi

  if [ "$BAN_BY_COUNTRY" == "true" ]; then
    envsubst < /sipwall-country.conf.tmpl > /etc/fail2ban/jail.d/sipwall-country.conf
  fi

  touch /init
fi


#Configure whitelist according to aparent public IP and whitelist
export PUBLIC_IP=""
if [ "$WHITELISTED_PUBLIC_IP" == "true" ]; then
  export PUBLIC_IP=$(curl -s ifconfig.me)
fi
export PRIVATE_IPS=""
if [ "$WHITELISTED_PRIVATE_IP" == "true" ]; then
  export PRIVATE_IPS="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
fi
echo "Adding whitelisted IPs. PUBLIC_IP=$PUBLIC_IP; PRIVATE_IP=$PRIVATE_IP; WHITELISTED_IPS=$WHITELISTED_IPS"
envsubst < /sipwall-whitelist.conf.tmpl > /etc/fail2ban/jail.d/sipwall-whitelist.conf


echo "Starting fail2ban with sip rejects filter activated..."
if [ "$LOG_LEVEL" == "DEBUG" ]; then
  VERBOSE="-vv"
fi
fail2ban-server -x $VERBOSE &


echo "Starting tcpdump routine..."

SIPWALL_INOUT_FILE="/var/log/sipwall-inout"
rm $SIPWALL_INOUT_FILE

while true; do

  if [ ! -f $SIPWALL_INOUT_FILE ]; then
    echo "Killing any existing tcpdump and grep processes..."
    pkill tcpdump
    pkill grep

    echo "Launching tcpdump for sending sip INOUT to $SIPWALL_INOUT_FILE..."
    touch $SIPWALL_INOUT_FILE
    tcpdump -n -i $TCPDUMP_INTERFACE port $TCPDUMP_PORT > $SIPWALL_INOUT_FILE &
  fi

  sleep 60

  #evaluate if log is too large and delete it if needed
  FILESIZE_INOUT=$(stat -c %s $SIPWALL_INOUT_FILE)
  if [ $FILESIZE_INOUT -gt 10000000 ]; then
    echo "Dump files too large. Deleting it and reinitializing tcpdump..."
    rm -f $SIPWALL_INOUT_FILE
  fi

done


