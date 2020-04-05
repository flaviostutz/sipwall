# sipwall
Analyses network traffic and blocks hosts that are suspicious in iptables.

Uses tcpdump for searching for hosts that are trying things that are denied by SIP gateway and if they retry a lot, place the requesting IP to a blacklist using fail2ban+iptables for a period of time.

## Usage

## Volumes

* **/var/lib/fail2ban/** - sqllite database location used controling blacklist expiration etc

