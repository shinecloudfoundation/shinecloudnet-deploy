# Deploy validator and sentry nodes

## Deploy sentry node

### Deploy
```shell
cd $HOME && wget https://raw.githubusercontent.com/shinecloudfoundation/shinecloudnet-deploy/master/mainnet/sentry-validator/deploy-sentry.sh -O deploy-sentry.sh && sh deploy-sentry.sh [moniker] [miniGasPrice] [version]
```

Example command:

```shell
cd $HOME && wget https://raw.githubusercontent.com/shinecloudfoundation/shinecloudnet-deploy/master/mainnet/sentry-validator/deploy-sentry.sh -O deploy-sentry.sh && sh deploy-sentry.sh myScloudNode 0.01uscds v1.0.0
```

### Get sentry node peer info

```
cd $HOME && ./scloud tendermint show-node-id --home $HOME/scloudNode
```
Example response: `fea337d074e7b38b26dd343f91c3928993298612`

Suppose the localnet IP of sentry node is `172.31.46.241`, then the sentry node peer info should be: `fea337d074e7b38b26dd343f91c3928993298612@172.31.46.241:26656`

## Deploy validator node

- Deploy validator
```shell
cd $HOME && wget https://raw.githubusercontent.com/shinecloudfoundation/shinecloudnet-deploy/master/mainnet/sentry-validator/deploy-validator.sh -O deploy-validator.sh && sh deploy-validator.sh [moniker] [miniGasPrice] [version] [sentryNodePeerInfo]
```

- Get validator node id
```
cd $HOME && ./scloud tendermint show-node-id --home $HOME/scloudNode
```
Example response: `960d2d076cb1e3397189333eae5c0396ea6d64c9`

## Make the validator peer info to be private on sentry node

On sentry node machine, execute this command:
```shell
wget https://raw.githubusercontent.com/shinecloudfoundation/shinecloudnet-deploy/master/mainnet/sentry-validator/private-validator.sh -O private-validator.sh && sh private-validator.sh [validator-node-id] [node-home-path]
```

Example command:

```shell
cd $HOME && wget https://raw.githubusercontent.com/shinecloudfoundation/shinecloudnet-deploy/master/mainnet/sentry-validator/private-validator.sh -O private-validator.sh && sh private-validator.sh acc6a758e843dde12fecdeccdf18f1c54f5f2961 $HOME/scloudNode
```
