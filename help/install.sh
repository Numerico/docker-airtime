#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

source /etc/apache2/envvars
sudo service rabbitmq-server start
sudo service apache2 start

mkdir ~/airtime

curl -L https://github.com/Numerico/airtime/archive/2.5.x.zip > /tmp/airtime.zip 
unzip /tmp/airtime.zip -d ~/airtime
sudo ~/airtime/airtime-2.5.x/install -fapi

sudo mkdir -p /srv/airtime/stor
sudo chown -R www-data:www-data /srv/airtime

#sudo cp ~/helpers/media /etc/airtime/media_monitor_logging.cfg

sudo service apache2 restart
sudo service postgresql restart
sleep 5
echo "DB"

#FILES=/usr/share/airtime/build/sql/*.sql
#for f in $FILES
#do
#  echo "Processing $f file..."
#  su postgres -c "PGPASSWORD=airtime psql -U airtime --dbname airtime -h localhost -f $f"
#done
IP=$(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')

curl \
-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
-X "X-Requested-With: XMLHttpRequest" \
-X "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12" \
-X "Accept: application/json, text/javascript, */*; q=0.01" \
-d "dbUser=airtime&dbPass=airtime&dbName=airtime&dbHost=localhost" -X POST \
http://${IP}/setup/setup-functions.php?obj=DatabaseSetup


curl \
-H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
-X "X-Requested-With: XMLHttpRequest" \
-X "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12" \
-X "Accept: application/json, text/javascript, */*; q=0.01" \
-d "mediaFolder=/srv/airtime/stor" -X POST \
http://${IP}/setup/setup-functions.php?obj=MediaSetup



sudo cp ~/helpers/htaccess /usr/share/airtime/public/.htaccess
sudo cp ~/helpers/config /etc/airtime/airtime.conf


sudo phpenmod opcache
sudo rm -rf ~/airtime

sudo apt-get clean
