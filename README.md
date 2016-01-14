Docker build of IIP Image Server with OPENJPEG
===========

A Dockfile deployment of IIP image server with OPENJPEG @ https://github.com/moravianlibrary/iipsrv-openjpeg

Docker hub respository @ https://hub.docker.com/r/bdlss/iipsrv.openjpeg

### Use  pre-built image
Download image from docker hub.

    $ docker pull bdlss/iipsrv.openjpeg

### Build from scratch
Use local Dockerfile to build image.

    $ docker build -t your_image_name .

### Start the container

    $ docker run -d -p 8080:80 bdlss/iipsrv.openjpeg

This will push the docker containers port 80 to your localhost port 8080. 

### Images

The Dockerfile creates a /images/ directory at the server root and downloads a test JPEG2000 from http://iiif-test.stanford.edu/67352ccc-d1b0-11e1-89ae-279075081939.jp2.

### Test

Point your browser to `http://<Host or Container IP>:8080?IIIF=/images/67352ccc-d1b0-11e1-89ae-279075081939.jp2`

### Documentation and examples

Further documentation and examples are available here http://iipimage.sourceforge.net/.
