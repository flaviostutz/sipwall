#!/bin/sh

if [ "$TCPDUMP_INTERFACE" == "" ]; then
  echo "ENV TCPDUMP_INTERFACE is required"
  exit 1
fi

tail -F /var/log/fail2ban.log&

if [ ! -f /init ]; then
  echo "Preparing config files according to ENVs..."
  # sed -i 's|logtarget = /var/log/fail2ban.log|logtarget = STDOUT|g' /etc/fail2ban/fail2ban.conf
  sed -i "s|loglevel = INFO|loglevel = $LOG_LEVEL|g" /etc/fail2ban/fail2ban.conf
  envsubst < /sipwall.conf.tmpl > /etc/fail2ban/jail.d/sipwall.conf
  touch /init
fi

echo "Starting fail2ban with sip rejects filter activated..."
#start server
fail2ban-server &

echo "Starting tcpdump for sending sip rejects to /var/log/sipwall..."
tcpdump -n -i $TCPDUMP_INTERFACE port $TCPDUMP_PORT | grep -E "SIP:.*\s[45][0-9][0-9]\s" > /var/log/sipwall&

#Check if all processes are OK
while /bin/true; do
  ps aux |grep tcpdump |grep -q -v grep
  TCPDUMP_STATUS=$?
  ps aux |grep fail2ban-server |grep -q -v grep
  FAIL2BAN_STATUS=$?

  if [ $TCPDUMP_STATUS -ne 0 -o $FAIL2BAN_STATUS -ne 0 ]; then
    echo "Either tcpdump or fail2ban has exited"
    exit 1
  fi
  sleep 1
done

