# sipwall
Analyses SIP network traffic and blocks hosts that are suspicious using ipset and iptables.

Uses tcpdump for searching for hosts that are trying things that are being denied by SIP gateway and if they retry a lot, place the requesting IP to a blacklist using fail2ban+iptables for a period of time. This is useful to block brute force attacks.

It is possible to deny access from packets coming from unauthorized countries too. See BAN_BY_COUNTRY and ALLOWED_COUNTRIES ENVs.

## Usage

* Create docker-compose.yml:

```yml
  sipwall:
    image: flaviostutz/sipwall
    network_mode: host
    privileged: true
    environment:
      - LOG_LEVEL=DEBUG
      - TCPDUMP_INTERFACE=eth0
      - BAN_DENIED_TRIALS=true
      - BAN_BY_COUNTRY=true
      - ALLOWED_COUNTRIES=BR
      - BAN_TIME_SECONDS=30
      - FAIL_TIME_WINDOW_SECONDS=60
      - FAIL_COUNT_IN_WINDOW=5
```

* Run ```docker-compose up -d```

* Check logs at ```docker-compose logs -f```

* Run ```iptables -L -n -v``` to check for new rules

* Run ```ipset list``` to check for blocked ips

* Run ```docker-compose exec sipwall fail2ban-client status sipwall-denied`` to check for fail2ban status

* Run ```docker-compose exec sipwall fail2ban-client status sipwall-country`` to check for fail2ban status

* Run ```docker-compose logs -f sipwall | grep "ALLOWED"``` to view countries being analysed

## ENVs

* **LOG_LEVEL** - one of CRITICAL, ERROR, WARNING, NOTICE, INFO, DEBUG. defaults to WARNING
* **BAN_TIME_SECONDS** - time for a host to be banned after identifying it as a threat. defaults to '300'
* **FAIL_TIME_WINDOW_SECONDS** - time window for counting failures in SIP responses sent to a particular host. defaults to '600'
* **FAIL_COUNT_IN_WINDOW** - number of failures sent to the host within the time window in order to mark this host as a threat. defaults to '10'
* **TCPDUMP_INTERFACE** - tcpdump network interface to listen to. required
* **TCPDUMP_PORT** - tcpdump incoming packet port to listen to. defaults to '5060'
* **BAN_DENIED_TRIALS** - enable ban of IPs that receives negations from SIP. It may be an IP that is trying lots of user/password combinations. defaults to 'true'
* **BAN_BY_COUNTRY** - check if IP from the packet source is from a list of authorized countries. Ban IP if not. defaults to 'false'
* **ALLOWED_COUNTRIES** - list of allowed IP countries separated by ' ' (space). defaults to 'BR'
* **WHITELISTED_IPS** - list of IPs/masks that won't be banned in any case. ex.: 201.34.32.75 89.32.0.0/16. The server public IP got with "curl ifconfig.me" will be used in whitelist too.
* **WHITELISTED_PUBLIC_IP** - Add public IP to whitelisted IPs. Public IP is resolved from "curl ifconfig.me"
* **WHITELISTED_PRIVATE_IP** - Add private IPs to whitelisted IPs. 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

### Example

If FAIL_TIME_WINDOW_SECONDS is 60s, FAIL_COUNT_IN_WINDOW is 10, and FAIL_COUNT_IN_WINDOW, it will permit 10 failtures per minute, after which the host will be blocked for 5 minutes so no packet will be accepted by the host.

## Volumes

* **/var/lib/fail2ban/** - sqllite database location. used for controling blacklist expiration etc

