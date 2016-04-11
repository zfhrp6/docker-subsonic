#!/bin/bash
docker run \
  --detach \
  --restart='always' \
  --name subsonic \
  --publish 8080:8080 \
  --volume "/path/to/music/:/opt/music/:ro" \
  jorispotier/rpi-subsonic
