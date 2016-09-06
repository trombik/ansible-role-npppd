#!/bin/sh
route add 172.16.0.0/16 192.168.21.254
route add 192.168.0.0/16 192.168.21.254
echo 127.0.0.1 `hostname` >> /etc/hosts
