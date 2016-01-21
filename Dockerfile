FROM ubuntu:14.04

MAINTAINER BDLSS, Bodleian Libraries, Oxford University <calvin.butcher@bodleian.ox.ac.uk>
ENV HOME /root 

# Update packages and install tools 
RUN apt-get update -y && apt-get install -y gcc g++ wget cmake make git apache2 libapache2-mod-fcgid openssl libssl-dev autoconf libtool libfcgi0ldbl libjpeg-turbo8 libjpeg-turbo8-dev libjpeg-dev libjpeg8  libjpeg8-dev libtiff4-dev zlib1g  libstdc++6 libmemcached-dev memcached libtiff-dev libpng-dev libz-dev libopenjpeg2 libopenjpeg-dev liblcms2-2 liblcms2-dev libpng12-0 libpng12-dev libmagic-dev libxml2-dev libxslt-dev

# download and compile openjpeg
WORKDIR /tmp/openjpeg
RUN git clone -b openjpeg-2.0 --single-branch https://github.com/uclouvain/openjpeg.git ./
RUN cmake . && make && make install

# download and compile iipsrv, sleeps prevent 'Text file busy' error
WORKDIR /tmp/iip
#RUN git clone -b openjpeg --single-branch https://github.com/stweil/iipsrv.git ./
RUN git clone https://github.com/moravianlibrary/iipsrv-openjpeg.git ./
#RUN chmod +x ./autogen.sh && sleep 2 && ./autogen.sh
RUN chmod +x ./configure && sleep 2 && sleep 2 && ./configure --with-openjpeg=/tmp/openjpeg && sleep 2 && make && make install

# make www dir and copy iip binary into fcgi bin
RUN mkdir -p /var/www/localhost/fcgi-bin
RUN cp src/iipsrv.fcgi /var/www/localhost/fcgi-bin

# copy over apache2.conf for apache
COPY /apache2.conf /etc/apache2/apache2.conf
COPY /001-iipsrv.conf /etc/apache2/sites-available/001-iipsrv.conf
# add usr/local/lib to /etc/ld.so.conf and run ldconfig
RUN printf "include /etc/ld.so.conf.d/*.conf\ninclude /usr/local/lib\n" > /etc/ld.so.conf && ldconfig

# create image dir and get test jp2 image
RUN mkdir -p /var/www/localhost/images/ \
	&& cd /var/www/localhost/images/ \
	&& wget http://iiif-test.stanford.edu/67352ccc-d1b0-11e1-89ae-279075081939.jp2 \
	&& chmod 777 67352ccc-d1b0-11e1-89ae-279075081939.jp2 \
	&& wget http://merovingio.c2rmf.cnrs.fr/iipimage/PalaisDuLouvre.tif \
	&& chmod 777 PalaisDuLouvre.tif \
	&& chown -R www-data:www-data /var/www/

# install python
#WORKDIR /tmp/python
#RUN apt-get install -y build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
#RUN wget http://python.org/ftp/python/2.7.6/Python-2.7.6.tgz \
#	&& tar -xvf Python-2.7.6.tgz \
#	&& cd Python-2.7.6 \
#	&& ./configure \
#	&& make \
#	&& checkinstall
RUN apt-get install -y python2.7 build-essential python-dev python-setuptools


# get python tools
WORKDIR tmp/pythontools
#RUN wget https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz \
#    && tar zxfv distribute-0.6.49.tar.gz \
#    && /usr/bin/python distribute-0.6.49/distribute_setup.py \
RUN easy_install pip \
    && pip install bottle \
    && pip install python-magic \
    && pip install lxml \
    && pip install Pillow

# get IIIF validator
WORKDIR /tmp
RUN wget --no-check-certificate https://pypi.python.org/packages/source/i/iiif-validator/iiif-validator-0.9.1.tar.gz \
	&& tar zxfv iiif-validator-0.9.1.tar.gz \
	&& rm iiif-validator-0.9.1.tar.gz

EXPOSE 80

# enable fcgid mod 
RUN a2enmod fcgid

# disable default site conf
RUN sudo a2dissite 000-default.conf

# enable our site conf
RUN sudo a2ensite 001-iipsrv.conf

# start apache when we run the container, validate the test image, and start an ongoing process to prevent the container from closing
CMD service apache2 start && python /tmp/iiif-validator-0.9.1/iiif-validate.py -s 127.0.0.1:80 -p "fcgi-bin/iipsrv.fcgi?IIIF=" -i var/www/localhost/images/67352ccc-d1b0-11e1-89ae-279075081939.jp2 --version=2.0 -v > /var/www/localhost/validation.txt && tail -f /dev/null
