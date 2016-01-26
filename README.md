Docker build of IIP Image Server 1.0 with OPENJPEG 2.0
==============================================

A Dockfile deployment of IIP image server with OPENJPEG @ https://github.com/stweil/iipsrv/tree/openjpeg and https://github.com/uclouvain/openjpeg/tree/openjpeg-2.0

Docker hub respository @ https://hub.docker.com/r/bdlss/iipsrv-openjpeg-docker/

Build successes are logged @ https://hub.docker.com/r/bdlss/iipsrv-openjpeg-docker/builds/

### Use  pre-built image
Download image from docker hub. Defaults to `latest` tag.

    $ docker pull bdlss/iipsrv-openjpeg-docker
    
### Build from scratch
Use local Dockerfile to build image. Defaults to `latest` tag.

    $ docker build -t --no-cache bdlss/iipsrv-openjpeg-docker .

### Start the container
Defaults to `latest` tag.

    $ docker run -d -p 80:80 bdlss/iipsrv-openjpeg-docker

This will push the docker container port 80 to your localhost port 80. Change the first parameter to 8080 if required (i.e. you already have a webserver running on your local machine).

### Images

The Dockerfile creates a `/var/www/localhost/images/` directory and downloads a test JPEG2000 from http://iiif-test.stanford.edu/67352ccc-d1b0-11e1-89ae-279075081939.jp2 and a test TIF from http://merovingio.c2rmf.cnrs.fr/iipimage/PalaisDuLouvre.tif.

### Test

Point your browser to `http://localhost/fcgi-bin/iipsrv.fcgi?IIIF=67352ccc-d1b0-11e1-89ae-279075081939.jp2/full/full/0/default.jpg`

Or `http://localhost/fcgi-bin/iipsrv.fcgi?IIIF=PalaisDuLouvre.tif/full/full/0/default.jpg`

~~After starting the container, you can IIIF validate your images from the command line:~~

To get to the command line use:

```bash
docker ps
docker exec -it <container ID> /bin/bash
```

Then:

`/tmp/iiif-validator-0.9.1/iiif-validate.py -s localhost:80 -p "fcgi-bin/iipsrv.fcgi?IIIF=" -i var/www/localhost/images/67352ccc-d1b0-11e1-89ae-279075081939.jp2 --version=2.0 -v` 

### Documentation and examples

Further documentation and examples are available here http://iipimage.sourceforge.net/.
