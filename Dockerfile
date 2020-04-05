FROM alpine:3.11.5

RUN apk add --no-cache iptables fail2ban tcpdump ipset gettext && \
    rm /etc/fail2ban/jail.d/alpine-ssh.conf && \
    mkfifo /var/log/sipwall

RUN mkfifo /var/log/fail2ban.log

ADD sipwall.conf.tmpl /
ADD sip-refused.conf /etc/fail2ban/filter.d/
ADD startup.sh /

ENV LOG_LEVEL 'INFO'
ENV BAN_TIME_SECONDS '300'
ENV FAIL_TIME_WINDOW_SECONDS '600'
ENV FAIL_COUNT_IN_WINDOW '10'
ENV TCPDUMP_INTERFACE ''
ENV TCPDUMP_PORT '5060'

VOLUME [ "/var/lib/fail2ban/" ]

CMD [ "/startup.sh" ]

