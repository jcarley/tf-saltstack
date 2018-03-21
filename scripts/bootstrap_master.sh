#!/usr/bin/env bash

apt-get update
apt-get install -y curl wget vim avahi-daemon libnss-mdns
curl -L https://bootstrap.saltstack.com -o /tmp/install-salt.sh
chmod +x /tmp/install-salt.sh
/tmp/install-salt.sh -M -P

cd /tmp
salt-key --gen-keys=myminion \
  --keysize=4096 \
  --gen-keys-dir=/tmp

# myminion.pem
# myminion.pub

