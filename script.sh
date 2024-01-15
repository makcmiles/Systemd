echo "Создание конфигурации"
touch /etc/sysconfig/watchlog
cat >> /etc/sysconfig/watchlog << EOF
# Configuration file for my watchlog service
# Place it to /etc/sysconfig

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF
echo "Создание watchlog.log по адресу /var/log"
touch /var/log/watchlog.log
echo "Создание скрипта"
touch /opt/watchlog.sh
cat >> /opt/watchlog.sh << EOF
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: Alarm, Master!"
else
exit 0
fi
EOF
echo "Права на запуск файла"
chmod +x /opt/watchlog.sh
echo "Создание сервиса и таймера"
touch /etc/systemd/system/watchlog.service
cat >> /etc/systemd/system/watchlog.service << EOF
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
EOF
touch /etc/systemd/system/watchlog.timer
cat >> /etc/systemd/system/watchlog.timer << EOF
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
EOF
systemctl start watchlog.timer

echo "Установка spawn-fcgi и пакеты"
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
echo "раскомментирование строк с переменными в /etc/sysconfig/spawn-fcgi"
sed -i '/SOCKET=/s/^#//' /etc/sysconfig/spawn-fcgi
sed -i '/OPTIONS=/s/^#//' /etc/sysconfig/spawn-fcgi

echo "Создание сервис-файла /etc/systemd/system/spawn-fcgi.service"
touch /etc/systemd/system/spawn-fcgi.service
cat >> /etc/systemd/system/spawn-fcgi.service << EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

echo "Запуск spawn-fcgi.service"
systemctl daemon-reload
systemctl enable --now spawn-fcgi.service
systemctl start spawn-fcgi

echo "Модифицирую файл httpd.service,/etc/sysconfig/httpd-first и /etc/sysconfig/httpd-second"
sed -i '23i\EnvironmentFile=/etc/sysconfig/httpd-%I' /usr/lib/systemd/system/httpd.service
echo "OPTIONS=-f conf/first.conf" >> /etc/sysconfig/httpd-first
echo "OPTIONS=-f conf/second.conf" >> /etc/sysconfig/httpd-second

echo "Копирую конфигурационные файлы, меняю второй конфигурационный файл"
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf 
echo "PidFile /var/run/httpd-second.pid" >> /etc/httpd/conf/second.conf 
systemctl start httpd@first
systemctl start httpd@second