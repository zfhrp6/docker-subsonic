#!/bin/bash
docker run \
  --detach \
  --restart='always' \
  --name subsonic \
  --publish 8080:8080 \
  --volume "/media/music/:/opt/music/:ro" \
  jorispotier/rpi-subsonic
