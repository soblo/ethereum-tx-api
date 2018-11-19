/*
KStarCoin 관련 API
*/
const express = require('express');
const router = express.Router();

const Controller = require('../controllers/kStarCoinController');
const controller = new Controller();

// compile
router.post('/compile', controller.compile);

// deploy
router.post('/deploy', controller.deploy);

// totalSupply
router.get('/total-supply', controller.getTotalSupply);

// balanceOf
router.get('/balance-of/:userAddress', controller.getBalanceOf);

// allowance
router.get('/allowance/:from/:to', controller.getAllowance);

// transfer
router.post('/transfer', controller.transfer);

// transferFrom
router.post('/transfer-from', controller.transferFrom);

// approve
router.post('/approve', controller.approve);

module.exports = router
