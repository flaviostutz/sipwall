FROM alpine:3.11.5

RUN apk add --no-cache iptables fail2ban tcpdump && \
    rm /etc/fail2ban/jail.d/alpine-ssh.conf && \
    mkfifo /var/log/sipwall

RUN mkfifo /var/log/fail2ban.log

ADD alpine-sipwall.conf /etc/fail2ban/jail.d/
ADD sip-refused.conf /etc/fail2ban/filter.d/
ADD startup.sh /

VOLUME [ "/var/lib/fail2ban/" ]

CMD [ "/startup.sh" ]

