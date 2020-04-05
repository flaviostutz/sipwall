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
  envsubst < /sipwall.conf.tmpl > /etc/fail2ban/jail.d/sipwall.conf

  touch /init
fi


echo "Starting fail2ban with sip rejects filter activated..."
if [ "$LOG_LEVEL" == "DEBUG" ]; then
  VERBOSE="-vv"
fi
fail2ban-server -x $VERBOSE &


echo "Starting tcpdump routine..."

SIPWALL_FILE="/var/log/sipwall"
rm $SIPWALL_FILE

while true; do

  if [ ! -f $SIPWALL_FILE ]; then
    echo "Killing any existing tcpdump and grep processes..."
    pkill tcpdump
    pkill grep
    echo "Launching tcpdump for sending sip rejects info to $SIPWALL_FILE..."
    touch $SIPWALL_FILE
    tcpdump -n -i $TCPDUMP_INTERFACE port $TCPDUMP_PORT | grep -E "SIP:.*\s[45][0-9][0-9]\s" > $SIPWALL_FILE &
  fi

  sleep 60

  #evaluate if log is too large and delete it if needed
  FILESIZE=$(stat -c %s $SIPWALL_FILE)
  if [ $FILESIZE -gt 1000000 ]; then
    echo "File $SIPWALL_FILE is too large. Deleting it and reinitializing tcpdump..."
    rm -f $SIPWALL_FILE
  fi

  # A=$(fail2ban-client status sipwall)
  # FAIL2BAN_STATUS=$?
  # if [ $FAIL2BAN_STATUS -ne 0 ]; then
  #   echo "fail2ban sipwall is not running"
  #   exit 1
  # fi

done


