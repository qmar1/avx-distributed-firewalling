#!/bin/bash

# This shell script as is will only work on AWS.
# Will need modifications for other CSPs or if run locally. 

# Variables
# Instance type might be useful in the future optimizations
# Use PvtIP for non pulic instances
# Public IP for public instances
User_Data_Log_File="/home/ubuntu/user_data_log.log"
#TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
#pvt_ip=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4`
#ec2_type=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type`
#pub_ip=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4`

file_size=100m # Size of file to create eg: 1g, 10g , 100m ...
intf=$(cat /etc/netplan/50-cloud-init.yaml | grep set-name | awk '{print $2}')
use_ip=$(ip add show $intf | grep -Ei "inet\b" | awk '{print $2}' | cut -d '/' -f1)

#if [[ pub_ip -eq " " ]]; then
#    use_ip=$pvt_ip
#else 
#    use_ip=$pub_ip
#fi

# Webserver simple index.html config
read -r -d '' webserv_config << EOF
<!DOCTYPE html>
<html>
<head>
<title>Website_1</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<style>
body {font-family: "Times New Roman", Georgia, Serif;}
h1, h2, h3, h4, h5, h6 {
  font-family: "Playfair Display";
  letter-spacing: 5px;
}
</style>
</head>
<body>
My Private IP : "$use_ip"
</body>
</html>
EOF

# NGINX Systemd Config 
read -r -d '' nginx_systemd_config << EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/bin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Nginx Configuration
read -r -d '' nginxconf << EOF
    events {}
    http {
    include mime.types;

    server {
    	listen 80;
    	server_name $use_ip;

	    root /var/www/nginx/static;
        location /download {
	    index largefile.txt;
	}
    }
    server {
       listen 443 ssl;
       server_name $use_ip;
       root /var/www/nginx/static;
       location /download {
            index largefile.txt;
        }

       ssl_certificate /etc/ssl/certs/web_host.crt;
       ssl_certificate_key /etc/ssl/private/web_host.key;

       ssl_protocols TLSv1.2;
       ssl_prefer_server_ciphers on;
       ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
    }
}
EOF
# Not used currently. Will need to add for better logging
command_success()
{
    cmd_return=$1
    cmd=$2
    now=$(date +"%Y-%m-%d:%I:%M:%S :")
    if [[ $cmd_return == 0 ]];then
        echo "$now success: $cmd" >> $User_Data_Log_File
    else 
        echo "$now failed: $cmd" >> $User_Data_Log_File
    fi
}
# Install tools 
# Iperf , traceroute , mtr
sudo apt update -y
sudo apt install iperf3 -y
cmd_status=$?
command_success $cmd_status "Installation of Iperf3"
sudo apt install inetutils-traceroute -y
cmd_status=$?
command_success $cmd_status "Installation of inetutils-traceroute"

# Download Nginx home directory
wget https://nginx.org/download/nginx-1.22.0.tar.gz
tar -zxvf nginx-1.22.0.tar.gz
# Install NGINX support libraries
# This might vary depending on OS and CSP. Below is for AWS ubuntu 20.04 AMI
sudo apt install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev gcc make -y
# Install NGINX with SSL module
cd nginx-1.22.0
sudo ./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
sudo make install
# Intialize NGINX systemd and configuration file and start NGINX service
sudo touch /lib/systemd/system/nginx.service
sudo echo "$nginx_systemd_config" | sudo tee /lib/systemd/system/nginx.service > /dev/null
sudo systemctl enable nginx
sudo systemctl start nginx
sudo echo "$nginxconf" | sudo tee /etc/nginx/nginx.conf > /dev/null
# Generate OpenSSL Certs for webhost:
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/web_host.key -out /etc/ssl/certs/web_host.crt -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Global Security/OU=IT Department/CN=webserver.avxtac.net"
sudo systemctl reload nginx
sudo mkdir -p /var/www/nginx/static/
sudo touch /var/www/nginx/static/index.html
sudo echo "$webserv_config" | sudo tee  /var/www/nginx/static/index.html > /dev/null

# Build large text file
cd /home/ubuntu/
sudo fallocate -l $file_size largefile.txt
cmd_status=$?
command_success $cmd_status "create largefile"
# Move large text file to /var/www/nginx/static/download
sudo mkdir -p /var/www/nginx/static/download
sudo mv /home/ubuntu/largefile.txt /var/www/nginx/static/download/
cmd_status=$?
command_success $cmd_status "move largefile to nginx downloads directory"