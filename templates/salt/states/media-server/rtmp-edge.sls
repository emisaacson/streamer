nginx_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://conf/nginx/nginx-media-rtmp-edge.conf
    - require:
      - cmd: nginx_with_rtmp