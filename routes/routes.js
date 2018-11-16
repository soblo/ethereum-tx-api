const bodyParser = require('body-parser');
const kStarLiveQuiz = require('./kstarlive-quiz');
const kStarCoin = require('./kstar-coin');

const router = (app) => {
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));

  app.use('/kstarlive-quiz', kStarLiveQuiz);
  app.use('/kstar-coin', kStarCoin);
}

module.exports = router;
