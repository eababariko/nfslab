#!/bin/bash
sudo -i
systemctl stop firewalld
systemctl disable firewalld
yum install iptables iptables-services -y
systemctl enable iptables.service
systemctl start iptables.service
iptables -F
iptables -X
iptables -Z
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT   -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT   -m conntrack --ctstate INVALID -j DROP
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 111 -j ACCEPT
iptables -A INPUT -p tcp --dport 2049 -j ACCEPT
iptables -A INPUT -p udp --dport 111 -j ACCEPT
iptables -A INPUT -p udp --dport 2049 -j ACCEPT
iptables -A INPUT -p tcp --dport 20048 -j ACCEPT
iptables -A INPUT -p udp --dport 37877 -j ACCEPT
iptables -A INPUT -p tcp --dport 49121 -j ACCEPT
iptables -A INPUT -p udp --dport 20048 -j ACCEPT
iptables -A INPUT -p tcp --dport 42201 -j ACCEPT
iptables -A INPUT -p udp --dport 60520 -j ACCEPT
iptables -P INPUT   DROP
iptables -P OUTPUT  ACCEPT
iptables -P FORWARD DROP
/sbin/iptables-save > /root/iptables
echo '/sbin/iptables-restore < /root/iptables' >> /etc/rc.d/rc.local
sed -i 's/IPTABLES_SAVE_ON_STOP="no"/IPTABLES_SAVE_ON_STOP="yes"/' /etc/sysconfig/iptables-config
sed -i 's/IPTABLES_SAVE_ON_RESTART="no"/IPTABLES_SAVE_ON_RESTART="yes"/' /etc/sysconfig/iptables-config
sed -i 's/# tcp=y/tcp=n/' /etc/nfs.conf
sed -i 's/# udp=y/udp=y/' /etc/nfs.conf
sed -i 's/# vers4=y/vers4=n/' /etc/nfs.conf
sed -i 's/# vers4.0=y/vers4.0=n/' /etc/nfs.conf
sed -i 's/# vers4.1=y/vers4.1=n/' /etc/nfs.conf
sed -i 's/# vers4.2=y/vers4.2=n/' /etc/nfs.conf
mkdir /var/nfs_share
echo '/var/nfs_share/ *(rw,sync)' > /etc/exports
mkdir /var/upload
chmod ugo+rwx /var/upload
echo '/var/upload/ *(rw,sync,no_root_squash,no_all_squash)' >> /etc/exports
exportfs -s
systemctl restart nfs-server
systemctl enable nfs-server
