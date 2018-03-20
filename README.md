
This repository contains configuration files for building a 
Docker (http://docker.io) image for the Subsonic media streamer 
runnable on a Raspberry Pi.

## Noteworthy

* Subsonic 6.0 (http://www.subsonic.org)

## Build your own image

```shell
$ docker build -t <your-name>/rpi-subsonic .
```

## Run a container with this image

```shell
$ docker run \
  --detach \
  --name subsonic \
  --publish 8080:8080 \
  --volume "/wherever/your/music/is:/opt/music/:ro" \
  <your-name>/rpi-subsonic

```

