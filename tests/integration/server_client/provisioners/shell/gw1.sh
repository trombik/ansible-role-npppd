#!/bin/sh
set -ex
sysctl net.pipex.enable=1
sysctl net.inet.ip.forwarding=1
echo 127.0.0.1 `hostname` >> /etc/hosts

cat > /etc/pf.conf <<'__EOF__'
ext_if = "em1"
int_if = "em2"
vagrant_if = "em0"

set skip on { lo, enc }
block log all
pass in quick proto tcp from any to { ($ext_if), ($int_if), ($vagrant_if) } port ssh
pass in quick on $ext_if from any to ($ext_if)
pass in quick on $int_if from ($int_if:network) to any tag NAT
match out on $ext_if from ($ext_if:network) to any nat-to ($ext_if) tagged NAT
pass out quick tagged NAT
pass in quick on pppx tag L2TP
pass out quick on pppx from (pppx) to any
pass out quick on $int_if tagged L2TP
pass out quick on $ext_if from ($ext_if) to any
pass out quick on $int_if from ($int_if) to any
pass out quick on $vagrant_if from ($vagrant_if) to any
__EOF__

pfctl -f /etc/pf.conf
