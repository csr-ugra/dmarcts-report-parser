FROM debian:13.2-slim

USER root

RUN apt update && apt install -y\
	libfile-mimeinfo-perl \
	libmail-imapclient-perl \
	libmime-tools-perl \
	libxml-simple-perl \
	libio-socket-inet6-perl \
	libio-socket-ip-perl \
	libperlio-gzip-perl \
	libmail-mbox-messageparser-perl \
	libdbd-mysql-perl \
	libdbd-pg-perl \
	tzdata \
	logrotate \
	unzip \
	cron \
	--no-install-recommends\
	&& rm -rf /var/lib/apt/lists/*

# logrotate
RUN mkdir /log
COPY --chown=root:root dmarcts-report-parser /etc/logrotate.d/

# dmarc-report-parser
WORKDIR /app

COPY --chown=root:root dbx_Pg.pl /app/
COPY --chown=root:root dbx_mysql.pl /app/
COPY --chown=root:root dmarcts-report-parser.pl /app/
RUN chmod +x /app/dmarcts-report-parser.pl

RUN echo "0 9,21 * * * cd /app && perl /app/dmarcts-report-parser.pl -i --info 2>&1 | tee -a /logs/dmarcts-report-parser.log > /proc/1/fd/1" > /etc/cron.d/dmarcts-report-parser-cron
RUN chmod 0644 /etc/cron.d/dmarcts-report-parser-cron
RUN crontab /etc/cron.d/dmarcts-report-parser-cron

CMD ["cron", "-f"]