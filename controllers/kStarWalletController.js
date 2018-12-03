require('dotenv').config();
const ContractBuilder = require('../helpers/contractBuilder');
const CONTRACT_NAME = 'KStarWallet';

class KStarWallet {

  async compile(req, res) {
    await ContractBuilder.compile(CONTRACT_NAME);
    res.send(`${contractName} is compiled`);
  }
  

}

module.exports = KStarWallet;
