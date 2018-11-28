require('dotenv').config();
const ContractBuilder = require('../helpers/contractBuilder');
// const Model = require('../models/kStarCoinModel');
// const model = new Model();
const CONTRACT_NAME = 'KStarWallet';

class KStarWalletController {

  async compile(req, res) {
    await ContractBuilder.compile(CONTRACT_NAME);
    res.send(`${contractName} is compiled`);
  }
  

}

module.exports = KStarWalletController;
