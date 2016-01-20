FROM ubuntu:14.04

MAINTAINER BDLSS, Bodleian Libraries, Oxford University <calvin.butcher@bodleian.ox.ac.uk>
ENV HOME /root 

# Update packages and install tools 
RUN apt-get update -y && apt-get install -y gcc g++ wget cmake make git apache2 libapache2-mod-fcgid openssl libssl-dev autoconf libtool libfcgi0ldbl libjpeg-turbo8 libjpeg-turbo8-dev libjpeg-dev libjpeg8  libjpeg8-dev libtiff4-dev zlib1g  libstdc++6 libmemcached-dev memcached libtiff-dev libpng-dev libz-dev libopenjpeg2 libopenjpeg-dev liblcms2-2 liblcms2-dev libpng12-0 libpng12-dev

# download and compile openjpeg
WORKDIR /tmp/openjpeg
RUN git clone -b openjpeg-2.1 --single-branch https://github.com/uclouvain/openjpeg.git ./
#RUN git clone https://github.com/uclouvain/openjpeg.git ./
#RUN git checkout openjpeg-2.1
RUN cmake . && make

# download and compile iipsrv, sleeps prevent 'Text file busy' error
WORKDIR /tmp/iip
RUN git clone -b openjpeg --single-branch https://github.com/stweil/iipsrv.git ./
# add the modified configure script
#COPY configure configure
RUN chmod +x ./configure && sleep 2 && sleep 2 && ./configure --with-openjpeg=/tmp/openjpeg && sleep 2 && make && make install

# make www dir and copy iip binary into fcgi bin
RUN mkdir -p /var/www/localhost/fcgi-bin
RUN cp src/iipsrv.fcgi /var/www/localhost/fcgi-bin

# copy over apache2.conf for apache
COPY /apache2.conf /etc/apache2/apache2.conf
COPY /001-iipsrv.conf /etc/apache2/sites-available/001-iipsrv.conf
# add usr/local/lib to /etc/ld.so.conf and run ldconfig
RUN echo "include usr/local/lib" >> /etc/ld.so.conf && ldconfig

# create image dir and get test jp2 image
RUN mkdir -p /var/www/localhost/images/ \
	&& cd /var/www/localhost/images/ \
	&& wget http://iiif-test.stanford.edu/67352ccc-d1b0-11e1-89ae-279075081939.jp2 \
	&& chmod 777 67352ccc-d1b0-11e1-89ae-279075081939.jp2 \
	&& wget http://merovingio.c2rmf.cnrs.fr/iipimage/PalaisDuLouvre.tif \
	&& chmod 777 PalaisDuLouvre.tif
	&& chown -R www-data:www-data /var/www/

EXPOSE 80

# enable fcgid mod 
RUN a2enmod fcgid

# disable default site conf
RUN sudo a2dissite 000-default.conf

# enable our site conf
RUN sudo a2ensite 001-iipsrv.conf

# start apache when we run the container and start an ongoing process
# to prevent the container from closing
CMD service apache2 start && tail -f /dev/null
