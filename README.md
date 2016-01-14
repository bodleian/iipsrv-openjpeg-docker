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

    $ docker run -d -p bdlss/iipsrv.openjpeg

### Images

Place your images into a directory that is accessible by your webserver. *All paths given to IIP server must be absolute, e.g. via the FIF or IIIF variable.*

### Test

Point your browser to, for example, `http://<Host or Container IP>IIIF=/path/to/images/<image_name>.tif/jpg/jp2`

### Documentation and examples

Further documentation and examples are available here http://iipimage.sourceforge.net/.
