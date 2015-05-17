{% set streamm1 = salt['mine.get']('stream-m01', 'network.ip_addrs').items()[0][1][0] %}
{% set streamm2 = salt['mine.get']('stream-m02', 'network.ip_addrs').items()[0][1][0] %}
{% set rtmp1 = salt['mine.get']('rtmp01', 'network.ip_addrs').items()[0][1][0] %}
{% set rtmp2 = salt['mine.get']('rtmp02', 'network.ip_addrs').items()[0][1][0] %}

nginx_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://conf/nginx/nginx-media-server.conf
    - template: jinja
    - defaults:
        streamm1: {{ streamm1 }}
        streamm2: {{ streamm2 }}
        rtmp1: {{ rtmp1 }}
        rtmp2: {{ rtmp2 }}
    - require:
      - cmd: nginx_with_rtmp