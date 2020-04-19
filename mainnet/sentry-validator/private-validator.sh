#!/bin/bash

validator_node_id=$1
nodeHome=$2

# Add validator to private peer list
sed -i -e "s/private_peer_ids = \"\"/private_peer_ids = \"$validator_node_id\"/g" $nodeHome/config/config.toml

sudo systemctl restart scloud-validator-daemon
