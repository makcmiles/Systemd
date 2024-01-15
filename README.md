```
1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig или в /etc/default).
2. Установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache2) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
```
Написал скрипт, при установке он выполняется. Конечная проверка даёт следующий результат
```
[vagrant@otuslinux ~]$ systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-01-15 00:41:34 UTC; 1min 45s ago
 Main PID: 5305 (php-cgi)
    Tasks: 33 (limit: 10992)
   Memory: 18.8M
   CGroup: /system.slice/spawn-fcgi.service
           ├─5305 /usr/bin/php-cgi
           ├─5308 /usr/bin/php-cgi
           ├─5309 /usr/bin/php-cgi
           ├─5310 /usr/bin/php-cgi
           ├─5311 /usr/bin/php-cgi
           ├─5312 /usr/bin/php-cgi
           ├─5313 /usr/bin/php-cgi
           ├─5314 /usr/bin/php-cgi
           ├─5315 /usr/bin/php-cgi
           ├─5316 /usr/bin/php-cgi
           ├─5317 /usr/bin/php-cgi
           ├─5318 /usr/bin/php-cgi
           ├─5319 /usr/bin/php-cgi
           ├─5320 /usr/bin/php-cgi
           ├─5321 /usr/bin/php-cgi
           ├─5323 /usr/bin/php-cgi
           ├─5324 /usr/bin/php-cgi
           ├─5325 /usr/bin/php-cgi
           ├─5326 /usr/bin/php-cgi
           ├─5327 /usr/bin/php-cgi
           ├─5328 /usr/bin/php-cgi
           ├─5329 /usr/bin/php-cgi
           ├─5330 /usr/bin/php-cgi
           ├─5331 /usr/bin/php-cgi
           ├─5332 /usr/bin/php-cgi
           ├─5333 /usr/bin/php-cgi
           ├─5334 /usr/bin/php-cgi
           ├─5335 /usr/bin/php-cgi
           ├─5336 /usr/bin/php-cgi
           ├─5337 /usr/bin/php-cgi
           ├─5339 /usr/bin/php-cgi
           ├─5340 /usr/bin/php-cgi
           └─5341 /usr/bin/php-cgi
```
```
[vagrant@otuslinux ~]$ systemctl status httpd@first
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-01-15 00:41:35 UTC; 2min 8s ago
     Docs: man:httpd@.service(8)
  Process: 5346 ExecStartPre=/bin/chown root.apache /run/httpd/instance-first (code=exited, status=0/SUCCESS)
  Process: 5344 ExecStartPre=/bin/mkdir -m 710 -p /run/httpd/instance-first (code=exited, status=0/SUCCESS)
 Main PID: 5348 (httpd)
   Status: "Running, listening on: port 80"
    Tasks: 214 (limit: 10992)
   Memory: 32.3M
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─5348 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─5350 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─5351 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─5352 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           ├─5353 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
           └─5354 /usr/sbin/httpd -DFOREGROUND -f conf/first.conf
[vagrant@otuslinux ~]$ systemctl status httpd@second
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2024-01-15 00:41:35 UTC; 2min 13s ago
     Docs: man:httpd@.service(8)
  Process: 5567 ExecStartPre=/bin/chown root.apache /run/httpd/instance-second (code=exited, status=0/SUCCESS)
  Process: 5355 ExecStartPre=/bin/mkdir -m 710 -p /run/httpd/instance-second (code=exited, status=0/SUCCESS)
 Main PID: 5570 (httpd)
   Status: "Running, listening on: port 8080"
    Tasks: 214 (limit: 10992)
   Memory: 33.6M
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─5570 /usr/sbin/httpd -DFOREGROUND -f conf/second.conf
           ├─5571 /usr/sbin/httpd -DFOREGROUND -f conf/second.conf
           ├─5572 /usr/sbin/httpd -DFOREGROUND -f conf/second.conf
           ├─5573 /usr/sbin/httpd -DFOREGROUND -f conf/second.conf
           ├─5574 /usr/sbin/httpd -DFOREGROUND -f conf/second.conf
           └─5575 /usr/sbin/httpd -DFOREGROUND -f conf/second.conf
```
```
[vagrant@otuslinux ~]$ sudo tail -f /var/log/messages
Jan 15 00:42:13 centos8s systemd[5799]: Listening on D-Bus User Message Bus Socket.
Jan 15 00:42:13 centos8s systemd[5799]: Reached target Sockets.
Jan 15 00:42:13 centos8s systemd[5799]: Reached target Basic System.
Jan 15 00:42:13 centos8s systemd[5799]: Reached target Default.
Jan 15 00:42:13 centos8s systemd[5799]: Startup finished in 129ms.
Jan 15 00:42:13 centos8s systemd[1]: Started User Manager for UID 1000.
Jan 15 00:42:13 centos8s systemd[1]: Started Session 4 of user vagrant.
Jan 15 00:42:16 centos8s systemd-udevd[636]: Network interface NamePolicy= disabled on kernel command line, ignoring.
Jan 15 00:44:35 centos8s systemd[5799]: Starting Mark boot as successful...
Jan 15 00:44:35 centos8s systemd[5799]: Started Mark boot as successful.
```