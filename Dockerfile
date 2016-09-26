FROM ubuntu:14.04.3

MAINTAINER BDLSS, Bodleian Libraries, Oxford University <calvin.butcher@bodleian.ox.ac.uk>
ENV HOME /root 

# Update packages and install tools 
RUN apt-get update -y && apt-get install -y build-essential wget cmake make git apache2 libapache2-mod-fcgid openssl libssl-dev autoconf libfcgi0ldbl libtool libjpeg-turbo8 libjpeg-turbo8-dev libtiff4-dev libpng12-0 libpng12-dev libmemcached-dev memcached liblcms2-2 liblcms2-dev libgomp1 libpthread-stubs0-dev liblzma5 liblzma-dev libjbig-dev libjbig0 libz80ex1 libz80ex-dev pkg-config

# Download and compile openjpeg2.1
WORKDIR /tmp/openjpeg
RUN git clone https://github.com/uclouvain/openjpeg.git ./
RUN git checkout tags/version.2.1
RUN cmake . && make && make install

RUN export USE_OPENJPEG=1

# add usr/local/lib to /etc/ld.so.conf and run ldconfig
RUN printf "include /etc/ld.so.conf.d/*.conf\ninclude /usr/local/lib\n" > /etc/ld.so.conf && ldconfig

# download and compile Stweil's iipsrv w/ openjpeg2.1, sleeps prevent 'Text file busy' error
WORKDIR /tmp/iip
RUN git clone https://github.com/stweil/iipsrv.git ./
RUN git checkout tags/openjpeg-20160529
RUN chmod +x autogen.sh && sleep 2 && ./autogen.sh
RUN chmod +x configure && sleep 2 && ./configure --with-openjpeg=/tmp/openjpeg && sleep 2 && make && make install

# make www dir and copy iip binary into fcgi bin
RUN mkdir -p /var/www/localhost/fcgi-bin
RUN cp src/iipsrv.fcgi /var/www/localhost/fcgi-bin

# copy over apache2.conf for apache
COPY /001-iipsrv.conf /etc/apache2/sites-available/001-iipsrv.conf

# create image dir and get test jp2 image, images are placed inside mapped host directory (see README)
RUN mkdir -p /var/www/localhost/images/ \
	&& chown -R www-data:www-data /var/www/

# install python
RUN apt-get install -y python2.7 build-essential python-dev python-setuptools libxml2-dev libxslt1-dev

# get python tools
WORKDIR /tmp/pythontools
RUN easy_install pip \
    && pip install bottle \
    && pip install python-magic \
    && pip install lxml \
    && pip install Pillow

# get IIIF validator
WORKDIR /tmp
RUN wget --no-check-certificate https://pypi.python.org/packages/source/i/iiif-validator/iiif-validator-1.0.0.tar.gz \
	&& tar zxfv iiif-validator-1.0.0.tar.gz \
	&& rm iiif-validator-1.0.0.tar.gz

EXPOSE 80

# enable fcgid mod 
RUN a2enmod fcgid

# disable default site conf
RUN sudo a2dissite 000-default.conf

# enable our site conf
RUN sudo a2ensite 001-iipsrv.conf

# start apache when we run the container and start an ongoing process to prevent the container from closing
CMD service apache2 start && tail -f /dev/null
