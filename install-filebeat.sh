#!/bin/bash
sudo -n true
if [ $? -ne 0 ]
then
	echo "This script requires user to have passwordless sudo access"
	exit
fi

sudo pgrep filebeat
if [ $? -ne 0 ]
then 
    wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.2-x86_64.rpm
    sudo rpm -vi /opt/filebeat-7.4.2-x86_64.rpm
    sudo cat >/etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/secure
    - /var/log/messages
    - /var/log/boot.log 
    - /var/log/yum.log
    - /var/log/cron  
### ( NOI DUNG THEM CHO ĐƯỜNG DẪN FIREWALL và SERVICES TRONG /VAR/LOG/[NAME_SERVICE]/*.log)
#   Log kernel
    - /var/log/kern
#   Log firewalld trên centos 7
#    - /var/log/firewalld
#   Log iptables tren centos 6
#    - /var/log/iptables
#    - /var/log/nginx/*.log
processors:
- drop_fields:
    fields: ["type", "beat", "prospector", "input", "offset"]

### Có thể thay đổi ip và port cho phù hợp với vị trí máy chủ đang chạy logstash
output.logstash:
#  hosts: ["118.70.194.13:2514"]
  hosts: ["172.30.206.252:2514"]
EOF
else
    sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bk
    sudo cat >/etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/secure
    - /var/log/message
    - /var/log/boot.log 
    - /var/log/yum.log
    - /var/log/cron  
### ( NOI DUNG THEM CHO ĐƯỜNG DẪN FIREWALL và SERVICES TRONG /VAR/LOG/[NAME_SERVICE]/*.log)
#   Log kernel
    - /var/log/kern
#   Log firewalld trên centos 7
#    - /var/log/firewalld
#   Log iptables tren centos 6
#    - /var/log/iptables
#    - /var/log/nginx/*.log
processors:
- drop_fields:
    fields: ["type", "beat", "prospector", "input", "offset"]

### Có thể thay đổi ip và port cho phù hợp với vị trí máy chủ đang chạy logstash
output.logstash:
#  hosts: ["118.70.194.13:2514"]
  hosts: ["172.30.206.252:2514"]
EOF
fi


version=$(rpm -q --queryformat '%{VERSION}' centos-release)
if [ $version -eq 7 ]
then
    echo "Centos 7"
    sudo systemctl daemon-reload
    sudo systemctl enable filebeat
    sudo systemctl start filebeat
else
    echo "Centos version old"
    sudo service filebeat start
fi
