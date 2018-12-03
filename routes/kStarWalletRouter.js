/**
 * KStarWallet API Context 정의
 */
const express = require('express');
const router = express.Router();

const KStarWallet = require('../controllers/kStarWallet.js');
const wallet = new KStarWallet();

/**
 * KStarWallet Compile 
 */
router.post('/compile', wallet.compile);

module.exports = router;
