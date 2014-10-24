#!/bin/bash

log_file="/tmp/log.out"
echo "Installing the DB2 UDB Server v10.5" | tee -a $log_file

mount -o loop /my_drive/rhel-server-6.5-x86_64-dvd.iso /mnt
repo_file=/etc/yum.repos.d/server.repo
echo "[server]" > $repo_file
echo "name=server" >> $repo_file
echo "baseurl=file:///mnt" >> $repo_file
echo "enabled=1" >> $repo_file
yum clean all
rpm --import /mnt/*GPG*
yum install libpam -y
yum install libaio -y
yum install libstdc++ -y

mkdir -p /tmp/db2_server

echo "Setting the hosts on file [/etc/hosts] for the topology."

echo "192.168.1.11 wl.company.com" > /etc/hosts
echo "192.168.1.10 db2.company.com" >> /etc/hosts


echo "Unziping the DB2 binaries" | tee -a $log_file
tar xvfz /vagrant/binary/DB2_Svr_10.5.0.3_Linux_x86-64.tar.gz -C /tmp/db2_server > /dev/null

echo "Installing DB2 v10.5 using response file" | tee -a $log_file 
/tmp/db2_server/server/db2setup -r /vagrant/db2ese.rsp | tee -a $log_file 

echo "Installation of DB2 v10.5 finished." | tee -a $log_file

echo "Creating user [wluser] which will be used as services account to connect on db2"
useradd wluser -g db2iadm1 -p wluser
echo "wluser" | passwd wluser --stdin

echo "Creating WORKLIGHT databases"

echo "Creating WORKLIGHT database [APPCNTR]"
sudo su - db2inst1 -c "db2 CREATE DATABASE APPCNTR COLLATE USING SYSTEM PAGESIZE 32768;
					   db2 CONNECT TO APPCNTR;
					   db2 GRANT CONNECT ON DATABASE TO USER wluser;
					   db2 DISCONNECT APPCNTR;
					   db2 connect reset"


echo "Creating WORKLIGHT database [WRKLGHT]"
sudo su - db2inst1 -c "db2 CREATE DATABASE WRKLGHT COLLATE USING SYSTEM PAGESIZE 32768;
					   db2 CONNECT TO WRKLGHT;
					   db2 GRANT CONNECT ON DATABASE TO USER wluser;
					   db2 DISCONNECT WRKLGHT;
					   db2 connect reset"

echo "Creating WORKLIGHT database [WLADMIN]"
sudo su - db2inst1 -c "db2 CREATE DATABASE WLADMIN COLLATE USING SYSTEM PAGESIZE 32768;
					   db2 CONNECT TO WLADMIN;
					   db2 GRANT CONNECT ON DATABASE TO USER wluser;
					   db2 DISCONNECT WLADMIN;
					   db2 connect reset"

exit 0