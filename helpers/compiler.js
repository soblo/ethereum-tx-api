const path = require('path');
const fs = require('fs');
const solc = require('solc');

const compiler = (contractName) => {
  const inputPath = path.resolve('contracts', `${contractName}.sol`);
  const outputPath = path.resolve('build', `${contractName}.json`);

  const inputData = fs.readFileSync(inputPath, 'utf8');
  const outputData = solc.compile(inputData, 1).contracts[`:${contractName}`];

  fs.writeFileSync(outputPath, JSON.stringify(outputData, null, ' '), 'utf8');
}

module.exports = compiler;
