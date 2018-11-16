const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const connection = require('../config/connection');

const provider = new HDWalletProvider(connection.mnemonic, connection.rpc.dev);
const web3 = new Web3(provider);

provider.engine.stop();

module.exports = web3;
