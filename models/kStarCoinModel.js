const contractName = 'KStarCoin';
const contractAddress = '0x1957C2e15cC6eb07A2A2c25D6e9458dC477a500f';
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
