FROM ubuntu:16.04
MAINTAINER Marco A. Harrendorf <marco.harrendorf@cern.ch>

VOLUME ["/data"]

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get -y dist-upgrade && apt-get -y install apache2 rcs diffutils zip cron make gcc g++ pkg-config libssl-dev cpanminus libcgi-pm-perl wget vim nano
RUN wget https://downloads.sourceforge.net/project/twiki/TWiki%20for%20all%20Platforms/TWiki-6.0.2/TWiki-6.0.2.tgz
RUN mkdir -p /var/www
RUN head TWiki-6.0.2.tgz
RUN tar xfv TWiki-6.0.2.tgz -C /var/www/
#RUN rm TWiki-6.0.2.tgz

ADD perl/cpanfile /tmp/cpanfile

RUN cd /tmp && cpanm -l /var/www/twiki/lib/CPAN --installdeps /tmp/ && rm -rf /.cpanm  /tmp/cpanfile /var/www/twiki/lib/CPAN/man

ADD configs/vhost.conf /etc/apache2/sites-available/twiki.conf
ADD configs/LocalLib.cfg  /var/www/twiki/bin/LocalLib.cfg
ADD configs/LocalSite.cfg /var/www/twiki/lib/LocalSite.cfg

RUN a2enmod cgi expires && a2dissite '*' && a2ensite twiki.conf && chown -cR www-data: /var/www/twiki
RUN a2enmod ssl 
RUN a2enmod rewrite

RUN wget http://twiki.org/p/pub/Plugins/LdapContrib/LdapContrib.tgz
#RUN rsync -vaz LdapContrib/LdapContrib.tgz /var/www/twiki/
RUN tar xfv LdapContrib.tgz -C /var/www/twiki/

ADD bin/prepare-env.sh /prepare-env.sh
RUN chmod +x /prepare-env.sh

ADD bin/run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

EXPOSE 80 443
