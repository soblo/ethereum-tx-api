const fs = require('fs');
const path = require('path');
const web3 = require('../helpers/web3Initializer');
const deployer = require('../helpers/deployer');
const compiler = require('../helpers/compiler');

const contractName = 'KStarCoin';

const contractPath = path.resolve('build', `${contractName}.json`);
const contractData = fs.readFileSync(contractPath, 'utf8');
const contractObj = JSON.parse(contractData);

const contractAddress = '0x1957C2e15cC6eb07A2A2c25D6e9458dC477a500f';
const contractInstance = new web3.eth.Contract(
  JSON.parse(contractObj.interface), contractAddress);

const compile = () => {
  return compiler(contractName);
}

const deploy = () => {
  return deployer(contractName);
}

const getTotalSupply = async () => {
  const accounts = await web3.eth.getAccounts();
  console.log(accounts);
  return await contractInstance.methods.totalSupply().call();
}

const getBalanceOf = async (userAddress) => {
  return await contractInstance.methods.balanceOf(userAddress).call();
}

const getAllowance = async (owner, spender) => {
  return await contractInstance.methods.allowance(owner, spender).call();
}

const transfer = async (to, value) => {
  const accounts = await web3.eth.getAccounts();
  const estimatedGas =
    await contractInstance.methods.transfer(to, value).estimateGas();
  const gasLimit = Math.floor(estimatedGas * 1.2);

  const result = await contractInstance.methods.transfer(to, value)
    .send({
      from: accounts[0],
      gas: gasLimit,
    });

  return result.transactionHash;
}

const transferFrom = async (from, to , value) => {
  const accounts = await web3.eth.getAccounts();
  const estimatedGas = await contractInstance.methods
    .transferFrom(from, to, value).estimateGas();
  const gasLimit = Math.floor(estimatedGas * 1.2);

  const result = await contractInstance.methods.transferFrom(from, to, value)
    .send({
      from: accounts[0],
      gas: gasLimit,
    });

  return result.transactionHash;
}

const approve = async (spender, value) => {
  const accounts = await web3.eth.getAccounts();
  const estimatedGas = await contractInstance.methods
    .approve(spender, value).estimateGas();
  const gasLimit = Math.floor(estimatedGas * 1.2);

  const result = await contractInstance.methods.approve(spender, value)
    .send({
      from: accounts[0],
      gas: gasLimit,
    });

  return result.transactionHash;
}

module.exports = {
  compile,
  deploy,
  getTotalSupply,
  getBalanceOf,
  getAllowance,
  transfer,
  transferFrom,
  approve,
}
