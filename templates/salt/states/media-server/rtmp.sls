
/var/www:
  file.directory:
    - user: root
    - group: root
    - file_mode: 755
    - makedirs: True
    - recurse:
      - user
      - group

add-apt-repository:
  cmd.run:
    - name: "add-apt-repository ppa:mc3man/trusty-media && apt-get update && touch /tmp/ffmpeg-repo"
    - creates: /tmp/ffmpeg-repo

curl:
  pkg:
    - installed

ffmpeg:
  pkg:
    - installed
    - require:
      - cmd: add-apt-repository

unzip:
  pkg:
    - installed

build-essential:
  pkg:
    - installed

zlib1g-dev:
  pkg:
    - installed

libssl-dev:
  pkg:
    - installed

libpcre3:
  pkg:
    - installed

libpcre3-dev:
  pkg:
    - installed

make:
  pkg:
    - installed

gcc:
  pkg:
    - installed

nginx_source:
  file.managed:
    - name: /usr/src/nginx.tar.gz
    - source: salt://nginx.tar.gz
    - user: root
    - group: root
    - mode: 644

rtmp_module:
  git.latest:
    - name: https://github.com/arut/nginx-rtmp-module.git
    - rev: master
    - target: /opt/rtmp
    - require:
      - pkg: git

nginx-media-server.sh:
  file.managed:
    - name: /opt/nginx-media-server.sh
    - source: salt://nginx-media-server.sh
    - user: root
    - group: root
    - mode: 644

nginx_with_rtmp:
  cmd.run:
    - name: bash /opt/nginx-media-server.sh && touch /usr/src/nginxinstalled
    - unless: test -f /usr/src/nginxinstalled
    - creates: /usr/src/nginxinstalled
    - require:
      - pkg: build-essential
      - pkg: zlib1g-dev
      - pkg: libpcre3
      - pkg: libssl-dev
      - pkg: libpcre3-dev
      - pkg: unzip
      - git: rtmp_module
      - file: nginx-media-server.sh
      - file: nginx_source


nginx_init:
  file.managed:
    - name: /etc/init.d/nginx
    - source: salt://conf/nginx/nginx-ubuntu
    - user: root
    - group: root
    - mode: 755

nginx_update_rcd:
  cmd.run:
    - name: update-rc.d nginx defaults

nginx:
  service:
    - running
    - enable: True
    - watch:
      - file: nginx_conf
    - require:
      - file: nginx_conf
      - pkg: ffmpeg
