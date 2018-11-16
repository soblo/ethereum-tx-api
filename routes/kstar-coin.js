/*
KStarCoin 관련 API
*/
const express = require('express');
const router = express.Router();

const controller = require('../controllers/kstar-coin');

// totalSupply
router.get('/total-supply', async (req, res) => {
  const totalSupply = await controller.getTotalSupply();
  res.send(`totalSupply : ${totalSupply}`);
});

// balanceOf
router.get('/balance-of/:userAddress', async (req, res) => {
  const balance = await controller.getBalanceOf(req.params.userAddress);
  res.send(`Balance of ${req.params.userAddress} : ${balance}`);
});

// allowance
router.get('/allowance/:owner/:spender', async (req, res) => {
  const allowance = await controller.getAllowance(req.params.owner, req.params.spender);
  res.send(`${req.params.owner} allow ${req.params.spender} to transfer ${allowance}`);
});

// compile
router.post('/compile', (req, res) => {
  controller.compile('KStarCoin');
  res.send('KStarCoin is compiled');
});

// deploy
router.post('/deploy', async (req, res) => {
  const contractAddress = await controller.deploy()
  res.send(`Deployed contract address : ${contractAddress}`);
});

// transfer
router.post('/transfer', async (req, res) => {
  const txHash = await controller.transfer(req.body.to, req.body.value);
  res.send(`Transaction Hash : ${txHash}`);
});

// transferFrom
router.post('/transfer-from', async (req, res) => {
  const txHash = await controller.transferFrom(req.body.from, req.body.to, req.body.value);
  res.send(`Transaction Hash : ${txHash}`);
});

// approve
router.post('/approve', async (req, res) => {
  const txHash = await controller.approve(req.body.spender, req.body.value);
  res.send(`Transaction Hash : ${txHash}`);
});

module.exports = router
