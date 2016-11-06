#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
packages="l2tp-ipsec-vpn lsof"

ip route add 192.168.0.0/16 dev eth1 || true
echo 127.0.0.1 `hostname` >> /etc/hosts
if apt-get -y install ${packages}; then
    :
else
    echo "apt-get failed, attempting to fix it by \"apt-get update\""
    apt-get update
    if apt-get -y install ${packages}; then
        :
    else
        echo "cannot install ${packages}"
        exit 1
    fi
fi
for line in `ls /proc/sys/net/ipv4/conf/*/send_redirects`; do echo 0 > $line ;done

cat > /etc/ipsec.conf <<__EOF__
version 2.0
config setup
    dumpdir=/var/run/pluto/
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v6:fd00::/8,%v6:fe80::/10
    oe=off
    protostack=auto

conn L2TP-PSK
     authby=secret
     pfs=no
     auto=add
     keyingtries=3
     dpddelay=30
     dpdtimeout=120
     dpdaction=clear
     rekey=yes
     ikelifetime=8h
     keylife=1h
     type=transport
     left=172.16.0.100
     leftprotoport=17/1701
     right=172.16.0.254
     rightprotoport=17/1701
__EOF__

cat > /etc/xl2tpd/xl2tpd.conf <<__EOF__
[lac vpn]
lns = 172.16.0.254
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
__EOF__

cat > /etc/ipsec.secrets <<__EOF__
%any 172.16.0.100 : PSK "password"
__EOF__

cat > /etc/ppp/options.l2tpd.client <<__EOF__
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-mschap-v2
noccp
noauth
idle 1800
mtu 1410
mru 1410
defaultroute
usepeerdns
debug
lock
connect-delay 5000
name foo
password password
__EOF__
service ipsec restart
service xl2tpd restart
sleep 10
ipsec auto --add L2TP-PSK
ipsec auto --up L2TP-PSK
xl2tpd-control connect vpn
sleep 10
route add -net  192.168.21.0 netmask 255.255.255.0 dev ppp0
