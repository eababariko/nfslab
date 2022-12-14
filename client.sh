#!/bin/bash
sudo -i
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
sed -i 's/127.0.1.1 client client/#127.0.1.1 client client/' /etc/hosts
echo '192.168.56.41 server.test.ru server' >> /etc/hosts
echo '192.168.56.40 client.test.ru client' >> /etc/hosts
yum install nfs-utils -y
systemctl enable nfs-server&&systemctl restart nfs-server
yum -y install krb5-workstation krb5-libs
mkdir /mnt/nfs_share
mount -t nfs 192.168.56.42:/var/nfs_share /mnt/nfs_share
echo '192.168.56.42:/var/nfs_share /mnt/nfs_share nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab
mkdir /mnt/upload
mount -t nfs 192.168.56.42:/var/upload /mnt/upload
echo '192.168.56.42:/var/upload /mnt/upload nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab
mkdir /mnt/nfs
mount -t nfs 192.168.56.41:/var/nfs /var/nfs
mv /var/nfs/krb5.conf /etc/krb5.conf
mv /var/nfs/client.keytab /etc/krb5.keytab
mkdir /mnt/secure
mount -t nfs server:/var/secure /var/secure/
echo '192.168.56.41:/var/secure /mnt/secure nfs sec=krb5p,rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab
