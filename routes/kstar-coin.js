/*
KStarCoin 관련 API
*/
const express = require('express');
const router = express.Router();

const deployer = require('../helpers/deployer');
const compiler = require('../helpers/compiler');

// totalSupply
router.get('/totalsupply', (req, res) => {
  res.send('totalSupply');
});

// balanceOf
router.get('/balanceof/:address', (req, res) => {
  res.send(req.params.address);
});

// allowance
router.get('/allowance/:owner/:spender', (req, res) => {
  res.send(`owner : ${req.params.owner}, spender: ${req.params.spender}`);
});

// compile
router.post('/compile', (req, res) => {
  compiler('KStarCoin');
  res.send('KStarCoin is compiled');
});

// deploy
router.post('/deploy', (req, res) => {
  deployer('KStarCoin').then(result => {
    res.send(`result : ${result}`);
  });
});

// transfer
router.post('/transfer', (req, res) => {
  res.send(`to : ${req.body.to}, value : ${req.body.value}`);
});

// transferFrom
router.post('/transferfrom', (req, res) => {
  res.send(`from: ${req.body.from}, to : ${req.body.to}, value : ${req.body.value}`);
});

// approve
router.post('/approve', (req, res) => {
  res.send(`spender : ${req.body.spender}, value : ${req.body.value}`);
});

module.exports = router
