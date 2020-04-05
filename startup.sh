#!/bin/sh


echo "Starting fail2ban with sip rejects filter activated..."
#send fail2ban logs to output
tail -F /var/log/fail2ban.log&
#start server
fail2ban-server &

echo "Starting tcpdump for sending sip rejects to /var/log/sipwall..."
tcpdump -n | grep -E "SIP:.*\s[45][0-9][0-9]\s" > /var/log/sipwall
