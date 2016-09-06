#!/bin/sh
set -ex
sysctl net.pipex.enable=1
sysctl net.inet.ip.forwarding=1
echo 127.0.0.1 `hostname` >> /etc/hosts
