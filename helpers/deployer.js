const fs = require('fs');
const path = require('path');
const web3 = require('./web3Initializer');

const deployer = async (contractName) => {
  const contractPath = path.resolve('build', `${contractName}.json`);
  const contractData = fs.readFileSync(contractPath, 'utf8');
  const contractObj = JSON.parse(contractData);

  const accounts = await web3.eth.getAccounts();
  const result = await new web3.eth.Contract(JSON.parse(contractObj.interface))
      .deploy({
        data: '0x' + contractObj.bytecode,
        arguments: []
      })
      .send({ from: accounts[0] });

  console.log('Contract Address : ', result.options.address);
  return result.options.address;
}

module.exports = deployer;
