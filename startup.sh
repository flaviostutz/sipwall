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


echo "Starting fail2ban with sip rejects filter activated..."
if [ "$LOG_LEVEL" == "DEBUG" ]; then
  VERBOSE="-vv"
fi
fail2ban-server -x $VERBOSE &


echo "Starting tcpdump routine..."

SIPWALL_IN_FILE="/var/log/sipwall-in"
rm $SIPWALL_IN_FILE

SIPWALL_OUT_FILE="/var/log/sipwall-out"
rm $SIPWALL_OUT_FILE

while true; do

  if [ ! -f $SIPWALL_IN_FILE ]; then
    echo "Killing any existing tcpdump and grep processes..."
    pkill tcpdump
    pkill grep

    echo "Launching tcpdump for sending sip OUT to $SIPWALL_OUT_FILE..."
    touch $SIPWALL_OUT_FILE
    tcpdump -n -i $TCPDUMP_INTERFACE src port $TCPDUMP_PORT > $SIPWALL_OUT_FILE &

    echo "Launching tcpdump for sending sip IN to $SIPWALL_IN_FILE..."
    touch $SIPWALL_IN_FILE
    tcpdump -n -i $TCPDUMP_INTERFACE dst port $TCPDUMP_PORT > $SIPWALL_IN_FILE &    
  fi

  sleep 60

  #evaluate if log is too large and delete it if needed
  FILESIZE_IN=$(stat -c %s $SIPWALL_IN_FILE)
  FILESIZE_OUT=$(stat -c %s $SIPWALL_OUT_FILE)
  if [ $FILESIZE_IN -gt 1000000 ] || [ $FILESIZE_OUT -gt 1000000 ]; then
    echo "Dump files too large. Deleting it and reinitializing tcpdump..."
    rm -f $SIPWALL_IN_FILE
    rm -f $SIPWALL_OUT_FILE
  fi

  # A=$(fail2ban-client status sipwall)
  # FAIL2BAN_STATUS=$?
  # if [ $FAIL2BAN_STATUS -ne 0 ]; then
  #   echo "fail2ban sipwall is not running"
  #   exit 1
  # fi

done


