#!/bin/sh

moniker=$1
gas_price=$2
version=$3

if [ -z "$moniker" ] || [ -z "$gas_price" ]
then
  echo "Wrong usage!! Correct usage: sh deploy.sh [moniker] [mini_gas_price]"
  exit 0
fi

sudo apt update

jqPath=$(which jq)
if [ -z "$jqPath" ]
then
  sudo apt install jq -y
fi

jqPath=$(which jq)
if [ -z "$jqPath" ]
then
  echo "Install jq failed, abort!"
  exit 0
fi

curDir=$(pwd)
username=$USER
nodeHome=scloudNode
networkType=shinecloudnet-mainnet
configUrl=https://raw.githubusercontent.com/shinecloudfoundation/shinecloudnet-binary/master

mkdir bin/$version -p

wget $configUrl/$networkType/binary/$version/scloud -O bin/$version/scloud
wget $configUrl/$networkType/binary/$version/scloudcli -O bin/$version/scloudcli
wget $configUrl/$networkType/genesis.json -O genesis.json
wget $configUrl/$networkType/networkConfig.json -O networkConfig.json
wget $configUrl/$networkType/scloud-validator-daemon -O scloud-validator-daemon
wget $configUrl/$networkType/scloud-validator-daemon.service -O scloud-validator-daemon.service

configFile=networkConfig.json

seed=$(jq -r .seed $configFile)
persistent_peers=$(jq -r .persistent_peers $configFile)

chmod +x bin/$version/scloud
chmod +x bin/$version/scloudcli
chmod +x scloud-validator-daemon

sed -i -e "s@{{WORKDIR}}@$curDir@g" scloud-validator-daemon
sed -i -e "s@{{VERSION}}@$version@g" scloud-validator-daemon
sed -i -e "s@{{SCLOUD_HOME}}@$nodeHome@g" scloud-validator-daemon
sed -i -e "s@{{USER_NAME}}@$username@g" scloud-validator-daemon
sed -i -e "s@{{USER_GROUP}}@$username@g" scloud-validator-daemon

sudo cp scloud-validator-daemon /etc/init.d/
sudo cp scloud-validator-daemon.service /etc/systemd/system

./bin/$version/scloud init $moniker --home $nodeHome
cp genesis.json $nodeHome/config/genesis.json

sed -i -e "s/minimum-gas-prices = \"\"/minimum-gas-prices = \"$gas_price\"/g" $nodeHome/config/app.toml

for index in $(jq -r '.upgrade | keys | .[]' $configFile); do
    upgradeName=$(jq -r .upgrade[$index].name $configFile)
    upgradeHeight=$(jq -r .upgrade[$index].height $configFile)

    sed -i -e "s/$upgradeName = 9223372036854775807/$upgradeName = $upgradeHeight/g" $nodeHome/config/app.toml
done

sed -i -e "s/seeds = \"\"/seeds = \"$seed\"/g" $nodeHome/config/config.toml
sed -i -e "s/persistent_peers = \"\"/persistent_peers = \"$persistent_peers\"/g" $nodeHome/config/config.toml
sed -i -e "s/index_all_tags = false/index_all_tags = true/g" $nodeHome/config/config.toml
sed -i -e "s/timeout_commit = \"1s\"/timeout_commit = \"5s\"/g" $nodeHome/config/config.toml
sed -i -e "s/log_level = \"main:info,state:info,\*:error\"/log_level = \"main:info,state:info,\*:none\"/g" $nodeHome/config/config.toml

# Enable remote access to node rpc
sed -i -e "s/127.0.0.1:26657/0.0.0.0:26657/g" $nodeHome/config/config.toml

sudo systemctl daemon-reload

sudo systemctl start scloud-validator-daemon
