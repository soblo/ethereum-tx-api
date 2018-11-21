const {beforeEach} = require('mocha');

const assert = require('assert');
const ganache = require('ganache-cli');
const options = { gasLimit: 0x9691b7 };
ganache.server(options);
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
require('events').EventEmitter.defaultMaxListeners = 0;

const compiledKStarCoin = require('../build/KStarCoin.json');

let accounts;
let kStarCoin;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    console.log(accounts);
    const estimateGas = await web3.eth.estimateGas({
        data : compiledKStarCoin.bytecode
    });

    kStarCoin = await new web3.eth.Contract(JSON.parse(compiledKStarCoin.interface))
        .deploy({ data: compiledKStarCoin.bytecode })
        .send({ from : accounts[0], gas : estimateGas });
 
 });

 describe('테스트 그룹....', () => {
    it('배포 여부', () => {
        assert.ok(kStarCoin.options.address);
    });
});