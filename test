sudo -i
apt-get update && apt-get -y install socat
curl https://get.acme.sh | sh
source ~/.bashrc
acme.sh --register-account -m sanmaoban@hotmail.com
acme.sh --issue -d julo.f3322.net --standalone -k ec-256 --force
mkdir /data
mkdir /data/julo.f3322.net
acme.sh --installcert -d julo.f3322.net --fullchainpath /data/julo.f3322.net/fullchain.crt --keypath /data/julo.f3322.net/julo.f3322.net.key --ecc --force
