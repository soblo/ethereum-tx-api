require('dotenv').config(); // for configuration

const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');

const provider = new HDWalletProvider(process.env.MNEMONIC_WORDS, process.env.RPC_ADDRESS);
const web3 = new Web3(provider);

provider.engine.stop();

module.exports = web3;
