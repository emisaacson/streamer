{% set media = salt['mine.get']('media01', 'network.ip_addrs').items()[0][1][0] %}

nginx_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://conf/nginx/nginx-media-hls-dash-edge.conf
    - template: jinja
    - defaults:
        media: {{ media }}
    - require:
      - cmd: nginx_with_rtmp