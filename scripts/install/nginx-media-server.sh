pushd /usr/src

tar xf nginx.tar.gz
mv nginx-* nginx
cd nginx
./configure --add-module=/opt/rtmp --with-http_ssl_module --with-http_realip_module
make
make install

popd
