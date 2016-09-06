#!/bin/sh
set -ex
sysctl net.pipex.enable=1
sysctl net.inet.ip.forwarding=1
echo 127.0.0.1 `hostname` >> /etc/hosts

cat > /etc/pf.conf <<'__EOF__'
ext_if = "em1"
int_if = "em2"
vagrant_if = "em0"
block log all
pass in on $vagrant_if proto tcp from any to ($vagrant_if) port ssh
pass in on $ext_if proto tcp from any to ($ext_if) port ssh
pass in on $int_if proto tcp from any to ($int_if) port ssh
pass in on $ext_if from any to ($ext_if)
pass in on $int_if from ($int_if:network) to any tag NAT
match out on $ext_if from ($ext_if:network) to any nat-to ($ext_if) tagged NAT
pass out tagged NAT
pass out on $ext_if from ($ext_if) to any
__EOF__

pfctl -f /etc/pf.conf
