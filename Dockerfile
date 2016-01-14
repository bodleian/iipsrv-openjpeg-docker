FROM ubuntu:14.04

MAINTAINER BDLSS, Bodleian Libraries, Oxford University <calvin.butcher@bodleian.ox.ac.uk>
ENV HOME /root 

# Update packages and install tools 
RUN apt-get update -y && apt-get install -y gcc g++ wget make git apache2 libapache2-mod-fcgid openssl libssl-dev autoconf libtool libfcgi0ldbl libjpeg-turbo8 libjpeg-turbo8-dev libjpeg-dev libjpeg8  libjpeg8-dev libtiff4-dev zlib1g  libstdc++6 libmemcached-dev memcached

WORKDIR /tmp/iip
RUN git clone https://github.com/moravianlibrary/iipsrv-openjpeg.git ./
RUN chmod +x ./configure && sleep 2 && ./configure && sleep 2 && make

# make www dir and copy iip binary into fcgi bin
RUN mkdir -p /var/www/localhost/fcgi-bin
RUN cp src/iipsrv.fcgi /var/www/localhost/fcgi-bin

# copy over http.conf for apache
COPY /apache2.conf /etc/apache2/apache2.conf
COPY /001-iipsrv.conf /etc/apache2/sites-available/001-iipsrv.conf

EXPOSE 80

# enable fcgid mod and start apache
RUN a2enmod fcgid
RUN sudo a2dissite 000-default.conf
RUN sudo a2ensite 001-iipsrv.conf

ENTRYPOINT service apache2 start

