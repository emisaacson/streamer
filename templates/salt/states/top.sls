base:
  media[0-9][0-9]:
    - shared.aws
    - media-server.rtmp
    - media-server.rtmp-server

  rtmp[0-9][0-9]:
    - shared.aws
    - media-server.rtmp
    - media-server.rtmp-edge

  hls-dash[0-9][0-9]:
    - shared.aws
    - media-server.rtmp
    - media-server.hls-dash-edge

  stream-m[0-9][0-9]:
    - shared.aws
    - media-server.rtmp
    - media-server.stream-m