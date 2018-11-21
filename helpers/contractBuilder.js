const path = require('path');
const fs = require('fs');
const solc = require('solc');
const web3 = require('./web3Initializer');

class ContractBuilder {

  static async compile(contractName) {
    const inputPath = path.resolve('contracts', `${contractName}.sol`);
    const outputPath = path.resolve('build', `${contractName}.json`);

    const inputData = fs.readFileSync(inputPath, 'utf8');
    const outputData = await solc.compile(inputData, 1)
      .contracts[`:${contractName}`];

    fs.writeFileSync(outputPath, JSON.stringify(outputData, null, ' '), 'utf8');
  }

  static async deploy(contractName, args) {
    const contractPath = path.resolve('build', `${contractName}.json`);
    const contractData = fs.readFileSync(contractPath, 'utf8');
    const contractObj = JSON.parse(contractData);

    const accounts = await web3.eth.getAccounts();
    const result = await new web3.eth
      .Contract(JSON.parse(contractObj.interface))
      .deploy({
        data: '0x' + contractObj.bytecode,
        arguments: args
      })
      .send({ from: accounts[0] });

    console.log('Contract Address : ', result.options.address);
    return result.options.address;
  }

}

module.exports = ContractBuilder;
