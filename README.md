Docker build of IIP Image Server 1.0 with OPENJPEG 2.0
==============================================

A Dockfile deployment of IIP image server with OPENJPEG @ https://github.com/moravianlibrary/iipsrv-openjpeg and https://github.com/uclouvain/openjpeg/tree/openjpeg-1.5

Docker hub respository @ https://hub.docker.com/r/bdlss/iipsrv.openjpeg

Build successes are logged @ https://hub.docker.com/r/bdlss/iipsrv-openjpeg-docker/builds/

### Use  pre-built image
Download image from docker hub.

    $ docker pull bdlss/iipsrv.openjpeg

### Build from scratch
Use local Dockerfile to build image.

    $ docker build -t your_image_name .

### Start the container

    $ docker run -d -p 80:80 bdlss/iipsrv.openjpeg

This will push the docker container port 80 to your localhost port 80. Change the first parameter to 8080 if required (i.e. you already have a webserver running on your local machine).

### Images

The Dockerfile creates a /images/ directory at the server root and downloads a test JPEG2000 from http://iiif-test.stanford.edu/67352ccc-d1b0-11e1-89ae-279075081939.jp2.

### Test

Point your browser to `http://<host or IP address>/fcgi-bin/iipsrv.fcgi?IIIF=67352ccc-d1b0-11e1-89ae-279075081939.jp2/full/full/0/default.jpg`

After starting the container, you can IIIF validate your images from the command line:

To get to the command line use:

```bash
docker ps
docker exec -it <container ID> /bin/bash
```

Then:

`/tmp/iiif-validator-0.9.1/iiif-validate.py -s localhost:80 -p "fcgi-bin/iipsrv.fcgi?IIIF=" -i var/www/localhost/images/67352ccc-d1b0-11e1-89ae-279075081939.jp2 --version=2.0 -v` 

### Documentation and examples

Further documentation and examples are available here http://iipimage.sourceforge.net/.
