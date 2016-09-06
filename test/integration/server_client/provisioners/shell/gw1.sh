#!/bin/sh
set -ex
sysctl net.pipex.enable=1
sysctl net.inet.ip.forwarding=1
