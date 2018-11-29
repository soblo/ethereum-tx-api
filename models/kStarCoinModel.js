const contractName = 'KStarCoin';
const contractAddress = '0xD358d4068d735fDC18fd4b2b1a8a1B8dD7a50C8C'; // rinkeby KStarCoin contract
const ContractModel = require('./contractModel');

class KStarCoinModel extends ContractModel {

  constructor() {
    super(contractName, contractAddress);
  }

  getTotalSupply() {
    return this.contract.methods.totalSupply().call();
  }

  getBalanceOf(userAddress) {
    return this.contract.methods.balanceOf(userAddress).call();
  }

  getAllowance(from, to) {
    return this.contract.methods.allowance(from, to).call();
  }

  getAccounts() {
    return this.web3.eth.getAccounts();
  }

  estimateGasTransfer(to, value) {
    return this.contract.methods.transfer(to, value).estimateGas()
  }

  estimateGasTransferFrom(from, to, value) {
    return this.contract.methods.transferFrom(from, to, value).estimateGas();
  }

  estimateGasApprove(to, value) {
    return this.contract.methods.approve(to, value).estimateGas();
  }

  transfer(from, to, value, gasLimit) {
    return this.contract.methods.transfer(to, value)
      .send({ from: from, gas: gasLimit });
  }

  transferFrom(from, to, value, gasLimit) {
    return this.contract.methods.transferFrom(from, to, value)
      .send({ from: from, gas: gasLimit });
  }

  approve(from, to, value, gasLimit) {
    return this.contract.methods.approve(to, value)
      .send({ from: from, gas: gasLimit });
  }
  
}

module.exports = KStarCoinModel;
