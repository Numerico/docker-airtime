FROM ubuntu:trusty

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV HOSTNAME localhost

MAINTAINER Roberto Soto <webmaster@numerica.cl>

ENV DEBIAN_FRONTEND=noninteractive

RUN locale-gen --purge en_US.UTF-8 && sudo dpkg-reconfigure locales && sudo echo -e 'LANG="$LANG"\nLANGUAGE="$LANGUAGE"\n' > /etc/default/locale

RUN echo "airtime   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers && adduser --disabled-password --gecos "" airtime && adduser --disabled-password --gecos "" icecast2
RUN echo "exit 0" > /usr/sbin/policy-rc.d
RUN apt-get update && apt-get install -y rabbitmq-server apache2 curl supervisor postgresql unzip python-pip


RUN pg_dropcluster 9.3 main && pg_createcluster --locale en_US.UTF-8 9.3 main
RUN echo "host    all             all             0.0.0.0/0 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

COPY alone.conf /etc/supervisor/conf.d/supervisord.conf

COPY help/install.sh /home/airtime/install.sh
RUN chmod +x /home/airtime/install.sh && chown airtime /home/airtime/install.sh && mkdir /home/airtime/helpers

USER airtime
COPY fixes /home/airtime/helpers
RUN /home/airtime/install.sh

VOLUME ["/srv/airtime/stor/", "/etc/airtime", "/var/tmp/airtime/", "/var/log/airtime", "/usr/share/airtime", "/usr/lib/airtime"]
VOLUME ["/var/tmp/airtime"]

VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

VOLUME ["/var/log/rabbitmq", "/var/lib/rabbitmq"]

VOLUME ["/var/log/icecast2", "/etc/icecast2"]


EXPOSE 80 8000

USER root

CMD ["/usr/bin/supervisord"]
