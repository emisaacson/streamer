nginx_conf:
  file.managed:
    - name: /usr/local/nginx/conf/nginx.conf
    - source: salt://conf/nginx/nginx-media-streamm-edge.conf
    - require:
      - cmd: nginx_with_rtmp

add-java-repository:
  cmd.run:
    - name: "add-apt-repository ppa:webupd8team/java && apt-get update && touch /tmp/java-repo"
    - creates: /tmp/java-repo

accept-java-license:
  cmd.run:
    - name: "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && touch /tmp/accepted"
    - creates: /tmp/accepted
    - require:
      - cmd: add-java-repository

oracle-java8-installer:
  pkg:
    - installed
    - require:
      - cmd: accept-java-license

ant:
  pkg:
    - installed

stream-m:
  git.latest:
    - name: https://github.com/vbence/stream-m
    - rev: hotfix-gh3
    - target: /opt/stream-m
    - require:
      - pkg: git
  file.managed:
    - name: /etc/init.d/stream-m
    - source: salt://conf/stream-m
    - user: root
    - group: root
    - mode: 755
  service:
    - running
    - enable: True
    - watch:
      - file: stream-m
    - require:
      - cmd: build-stream-m
      - file: stream-m

build-stream-m:
  cmd.run:
    - name: "ant jar"
    - cwd: /opt/stream-m
    - creates: /opt/stream-m/dist
    - require:
      - git: stream-m
      - pkg: ant
      - pkg: oracle-java8-installer