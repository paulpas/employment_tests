devsrv1 198.61.177.89 User: testuser Pass: RgF8w5vn4j4K Root Pass: RgF8w5vn4j4K

1) Write/install a script that will compress any log files that have modification dates of over 5 days ago using gzip format. Please also delete any compressed files that are over 45 days old. The working directory is in /var/log/syslog. *Empty directories should be removed as well.*


2) Install apache and set the docroot to /usr/local/webapp. Enable mod_status and configure apache to allow access to /server-status from 127.0.0.1


3) Write a script that will run from cron that accesses /server-status and parses out the following values:
 - CPU load %
 - Requests/sec
 - Idle workers
 - # Requests being processed

Print these values using the following format:
"cpu: <CPU Load> rps: <Requests Per Second> iw: <Idle workers> cr: <Current Requests Being Processed>"


4) Modify the iptables rules to permit traffic destin to the webapp on tcp port 80, but only on its public facing ip.
