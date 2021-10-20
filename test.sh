sudo -i
apt-get update && apt-get -y install socat
curl https://get.acme.sh | sh
source ~/.bashrc
acme.sh --register-account -m sanmaoban@hotmail.com
acme.sh --issue -d julo.f3322.net --standalone -k ec-256 --force
mkdir /data
mkdir /data/julo.f3322.net
acme.sh --installcert -d julo.f3322.net --fullchainpath /data/julo.f3322.net/fullchain.crt --keypath /data/julo.f3322.net/julo.f3322.net.key --ecc --force

cd /usr/local/src
wget -nc --no-check-certificate https://www.openssl.org/source/openssl-1.1.1g.tar.gz -P /usr/local/src
tar -zxvf  /usr/local/src/openssl-1.1.1g.tar.gz  -C /usr/local/src

apt  -y install build-essential libpcre3 libpcre3-dev zlib1g-dev git  dbus manpages-dev aptitude g++

wget -nc --no-check-certificate http://nginx.org/download/nginx-1.18.0.tar.gz -P /usr/local/src
tar -zxvf /usr/local/src/nginx-1.18.0.tar.gz -C /usr/local/src

cd /usr/local/src/nginx-1.18.0
mkdir /etc/nginx

./configure --prefix=/etc/nginx \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-pcre \
        --with-http_realip_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_secure_link_module \
        --with-http_v2_module \
        --with-cc-opt='-O3' \
        --with-openssl=../openssl-1.1.1g


make && make install

sed -i 's/#user  nobody;/user  root;/' /etc/nginx/conf/nginx.conf
sed -i 's/worker_processes  1;/worker_processes  3;/' /etc/nginx/conf/nginx.conf
sed -i 's/    worker_connections  1024;/    worker_connections  4096;/' /etc/nginx/conf/nginx.conf
sed -i '$i include conf.d/*.conf;' /etc/nginx/conf/nginx.conf


rm -rf /usr/local/src/nginx-1.18.0
rm -rf /usr/local/src//nginx-1.18.0.tar.gz 
rm -rf /usr/local/src//openssl-1.1.1g
rm -rf /usr/local/src/openssl-1.1.1g.tar.gz


mkdir /etc/nginx/conf/conf.d
cat >/etc/nginx/conf/conf.d/default.conf <<EOF
  server {
    listen 80;
    server_name julo.f3322.net;
    root /usr/wwwroot;
    ssl on;
    ssl_certificate   /data/julo.f3322.net/fullchain.crt;
    ssl_certificate_key  /data/julo.f3322.net/julo.f3322.net.key;
	ssl_ciphers                 TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers    on;
    ssl_protocols                TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_session_cache            shared:SSL:50m;
    ssl_session_timeout          1d;
    ssl_session_tickets          on;
}
EOF
cat >/etc/systemd/system/nginx.service <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
PIDFile=/etc/nginx/logs/nginx.pid
ExecStartPre=/etc/nginx/sbin/nginx -t
ExecStart=/etc/nginx/sbin/nginx -c /etc/nginx/conf/nginx.conf
ExecReload=/etc/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
systemctl enable nginx
systemctl daemon-reload
systemctl restart nginx

mkdir /usr/wwwroot
git clone https://github.com/HFIProgramming/mikutap.git /usr/wwwroot


mkdir /etc/trojan
mkdir /etc/trojan/bin

wget --no-check-certificate -O /etc/trojan/bin/trojan-go-linux-amd64.zip "https://github.com/p4gefau1t/trojan-go/releases/download/v0.4.10/trojan-go-linux-amd64.zip"

apt -y install unzip

unzip -o -d /etc/trojan/bin /etc/trojan/bin/trojan-go-linux-amd64.zip

mkdir /etc/trojan/conf
cat >/etc/trojan/conf/server.json <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port":505,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "log_level": 1,
  "log_file": "",
  "password": [
       "kifsy1-pucbaj-zabcyv"
  ],
  "buffer_size": 32,
  "dns": [],
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "/data/julo.f3322.net/fullchain.crt",
    "key": "/data/julo.f3322.net/julo.f3322.net.key",
    "key_password": "",
    "cipher": "",
    "cipher_tls13": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "julo.f3322.net",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_port": 1234,
    "fingerprint": "firefox",
    "serve_plain_text": false
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "prefer_ipv4": false,
    "fast_open": false,
    "fast_open_qlen": 20
  },
  "mux": {
    "enabled": false,
    "concurrency": 8,
    "idle_timeout": 60
  },
  "router": {
    "enabled": false,
    "bypass": [],
    "proxy": [],
    "block": [],
    "default_policy": "proxy",
    "domain_strategy": "as_is",
    "geoip": "./geoip.dat",
    "geosite": "./geoip.dat"
  },
  "websocket": {
    "enabled": false,
    "path": "",
    "hostname": "127.0.0.1",
    "obfuscation_password": "",
    "double_tls": false,
    "ssl": {
      "verify": true,
      "verify_hostname": true,
      "cert": "/data/julo.f3322.net/fullchain.crt",
      "key": "/data/julo.f3322.net/julo.f3322.net.key",
      "key_password": "",
      "prefer_server_cipher": false,
      "sni": "",
      "session_ticket": true,
      "reuse_session": true,
      "plain_http_response": ""
    }
  },
  "forward_proxy": {
    "enabled": false,
    "proxy_addr": "",
    "proxy_port": 0,
    "username": "",
    "password": ""
  },
  "mysql": {
    "enabled": false,
    "server_addr": "localhost",
    "server_port": 3306,
    "database": "",
    "username": "",
    "password": "",
    "check_rate": 60
  },
  "redis": {
    "enabled": false,
    "server_addr": "localhost",
    "server_port": 6379,
    "password": ""
  },
  "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0
  }
}
EOF

cat >/etc/systemd/system/trojan.service<< EOF
[Unit]
Description=trojan
Documentation=sanmaoban
After=network.target

[Service]
Type=simple
StandardError=journal
PIDFile=/usr/src/trojan/trojan/trojan.pid
ExecStart=/etc/trojan/bin/trojan-go -config /etc/trojan/conf/server.json
ExecStop=/etc/trojan/bin/trojan-go
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart trojan
systemctl enable trojan 
