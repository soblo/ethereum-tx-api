/**
 * KStarWallet API Context 정의
 */
const express = require('express');
const router = express.Router();

const KStarWalletController = require('../controllers/kStarWalletController.js');
const controller = new KStarWalletController();

/**
 * KStarWallet Compile 
 */
router.post('/compile', controller.compile);

module.exports = router;
