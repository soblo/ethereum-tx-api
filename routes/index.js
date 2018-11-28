const bodyParser = require('body-parser');
const kStarLiveQuizRouter = require('./kStarLiveQuizRouter');
const kStarCoinRouter = require('./kStarCoinRouter');
const kStarWalletRouter = require('./kStarWalletRouter');

const router = (app) => {
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));

  app.use('/kstarlive-quiz', kStarLiveQuizRouter);
  app.use('/kstar-coin', kStarCoinRouter);
  app.use('/api/wallet', kStarWalletRouter);
}

module.exports = router;
