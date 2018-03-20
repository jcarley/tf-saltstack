#!/usr/bin/env bash

apt-get update
apt-get install -y curl wget vim avahi-daemon libnss-mdns
curl -L https://bootstrap.saltstack.com -o /tmp/install-salt.sh
chmod +x /tmp/install-salt.sh
/tmp/install-salt.sh -P
