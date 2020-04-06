FROM alpine:3.11.5

RUN apk add --no-cache iptables fail2ban tcpdump ipset gettext perl whois curl && \
    rm /etc/fail2ban/jail.d/alpine-ssh.conf

RUN mkfifo /var/log/fail2ban.log

RUN rm -rf /etc/fail2ban/filter.d/* && \
    rm -rf /etc/fail2ban/action.d/*

ADD sipwall-denied.conf.tmpl /
ADD sipwall-denied-filter.conf /etc/fail2ban/filter.d/
ADD sipwall-ipset-action.conf /etc/fail2ban/action.d/

ADD sipwall-country.conf.tmpl /
ADD sipwall-all-filter.conf /etc/fail2ban/filter.d/
ADD sipwall-country-action.conf /etc/fail2ban/action.d/
ADD authorized-country.sh /
ADD add-ipset-not-country.sh /

ADD startup.sh /

ENV LOG_LEVEL 'INFO'
ENV BAN_TIME_SECONDS '300'
ENV FAIL_TIME_WINDOW_SECONDS '600'
ENV FAIL_COUNT_IN_WINDOW '10'
ENV TCPDUMP_INTERFACE ''
ENV TCPDUMP_PORT '5060'
ENV BAN_DENIED_TRIALS 'true'
ENV BAN_BY_COUNTRY 'false'
ENV ALLOWED_COUNTRIES 'BR'
ENV WHITELISTED_IPS ''
ENV WHITELISTED_PUBLIC_IP 'true'

#SQLITE DB
VOLUME [ "/var/lib/fail2ban/" ]

CMD [ "/startup.sh" ]

