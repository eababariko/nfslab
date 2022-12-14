#!/bin/bash
sudo -i
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
sed -i 's/127.0.1.1 server server/#127.0.1.1 server server/' /etc/hosts
echo '192.168.56.41 server.nfslab.ru server' >> /etc/hosts
echo '192.168.56.40 client.nfslab.ru client' >> /etc/hosts
yum -y install krb5-server krb5-libs krb5-workstation
sed -i 's/# default_realm = EXAMPLE.COM/default_realm = NFSLAB.RU/' /etc/krb5.conf
sed -i 's/# EXAMPLE.COM = {/NFSLAB.RU = {/' /etc/krb5.conf
sed -i 's/#  kdc = kerberos.example.com/kdc = server.nfslab.ru/' /etc/krb5.conf
sed -i 's/#  admin_server = kerberos.example.com/admin_server = server.nfslab.ru/' /etc/krb5.conf
sed -i 's/# }/}/' /etc/krb5.conf
sed -i 's/# .example.com = EXAMPLE.COM/.nfslab.ru = NFSLAB.RU/' /etc/krb5.conf
sed -i 's/# example.com = EXAMPLE.COM/nfslab.ru = NFSLAB.RU/' /etc/krb5.conf
kdb5_util create -s
echo '*/admin@NFSLAB.RU       *' > /var/kerberos/krb5kdc/kadm5.acl
kadmin.local -q "addprinc root/admin"
kadmin.local -q "addprinc -randkey host/server.nfslab.ru"
kadmin.local -q "addprinc -randkey host/client.nfslab.ru"
kadmin.local -q "addprinc -randkey nfs/server.nfslab.ru"
kadmin.local -q "addprinc -randkey nfs/client.nfslab.ru"
kadmin.local -q "ktadd -norandkey -k /tmp/server.keytab nfs/server.nfslab.ru"
kadmin.local -q "ktadd -norandkey -k /tmp/client.keytab nfs/client.nfslab.ru"
systemctl enable krb5kdc.service&&systemctl restart krb5kdc.service&&systemctl status krb5kdc.service
systemctl enable kadmin.service&&systemctl restart kadmin.service&&systemctl status kadmin.service
cp /tmp/server.keytab /etc/krb5.keytab
yum install nfs-utils -y
mkdir -p /var/secure/
chmod 777 /var/secure/
echo '/var/secure *(rw,sec=krb5p)' > /etc/exports
echo 'RPCNFSDARGS="-V 4"' > /etc/sysconfig/nfs
systemctl enable nfs-server&&systemctl restart nfs-server&&systemctl status nfs-server
mkdir -p /var/nfs
chmod 777 /var/nfs/
echo '/var/nfs *(rw)' >> /etc/exports
cp /etc/krb5.conf /var/nfs/krb5.conf
cp /tmp/client.keytab /var/nfs/
chmod go+r /var/nfs/client.keytab

