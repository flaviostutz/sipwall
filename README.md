# sipwall
Analyses SIP network traffic and blocks hosts that are suspicious in iptables.

Uses tcpdump for searching for hosts that are trying things that are denied by SIP gateway and if they retry a lot, place the requesting IP to a blacklist using fail2ban+iptables for a period of time.

## Usage

* Create docker-compose.yml:

```yml
  sipwall:
    image: flaviostutz/sipwall
    network_mode: host
    privileged: true
    environment:
      - LOG_LEVEL=INFO
      - TCPDUMP_INTERFACE=eth0
```

* Run ```docker-compose up -d```

* Check logs at ```docker-compose logs -f```

## ENVs

* **LOG_LEVEL** - one of CRITICAL, ERROR, WARNING, NOTICE, INFO, DEBUG. defaults to INFO

* **BAN_TIME_SECONDS** - time for a host to be banned after identifying it as a threat. defaults to '300'
* **FAIL_TIME_WINDOW_SECONDS** - time window for counting failures in SIP responses sent to a particular host. defaults to '600'
* **FAIL_COUNT_IN_WINDOW** - number of failures sent to the host within the time window in order to mark this host as a threat. defaults to '10'
* **TCPDUMP_INTERFACE** - tcpdump network interface to listen to. required
* **TCPDUMP_PORT** - tcpdump incoming packet port to listen to. defaults to '5060'

### Example

If FAIL_TIME_WINDOW_SECONDS is 60s, FAIL_COUNT_IN_WINDOW is 10, and FAIL_COUNT_IN_WINDOW, it will permit 10 failtures per minute, after which the host will be blocked for 5 minutes so no packet will be accepted by the host.

## Volumes

* **/var/lib/fail2ban/** - sqllite database location. used for controling blacklist expiration etc

