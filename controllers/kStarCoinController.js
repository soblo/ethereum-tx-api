const ContractBuilder = require('../helpers/contractBuilder');
const Model = require('../models/kStarCoinModel');
const model = new Model();

const contractName = 'KStarCoin';
const GAS_LIMIT_MULTIPLE = 1.2;

class KStarCoinController {

  async compile(req, res) {
    await ContractBuilder.compile(contractName);
    res.send(`${contractName} is compiled`);
  }

  async deploy(req, res) {
    const contractAddress = await ContractBuilder.deploy(contractName);

    res.send(`Deployed contract address : ${contractAddress}`);
  }

  async getTotalSupply(req, res) {
    const totalSupply = await model.getTotalSupply();

    res.send(`totalSupply : ${totalSupply}`);
  }

  async getBalanceOf(req, res) {
    const userAddress = req.params.userAddress;

    const balance = await model.getBalanceOf(userAddress);

    res.send(`Balance of ${req.params.userAddress} : ${balance}`);
  }

  async getAllowance(req, res) {
    const from = req.params.from;
    const to = req.params.to;

    const allowance = await model.getAllowance(from, to);

    res.send(`${from} allow ${to} to transfer ${allowance}`);
  }

  async transfer(req, res) {
    const to = req.body.to;
    const value = req.body.value;

    const accounts = await model.getAccounts();
    const estimatedGas = await model.estimateGasTransfer(to, value);
    const gasLimit = Math.floor(estimatedGas * GAS_LIMIT_MULTIPLE);
    const result = await model.transfer(accounts[0], to, value, gasLimit);

    res.send(`Transaction Hash : ${result.transactionHash}`);
  }

  async transferFrom(req, res) {
    const from = req.body.from;
    const to = req.body.to;
    const value = req.body.value;

    const accounts = await model.getAccounts();
    const estimatedGas = await model.estimateGasTransferFrom(from, to, value);
    const gasLimit = Math.floor(estimatedGas * GAS_LIMIT_MULTIPLE);
    const result = await model.transferFrom(from, to, value, gasLimit);

    res.send(`Transaction Hash : ${result.transactionHash}`);
  }

  async approve(req, res) {
    const to = req.body.to;
    const value = req.body.value;

    const accounts = await model.getAccounts();
    const estimatedGas = await model.estimateGasApprove(to, value);
    const gasLimit = Math.floor(estimatedGas * GAS_LIMIT_MULTIPLE);
    const result = await model.approve(accounts[0], to, value, gasLimit);

    res.send(`Transaction Hash : ${result.transactionHash}`);
  }

}

module.exports = KStarCoinController;
