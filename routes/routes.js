const bodyParser = require('body-parser');
const kStarLiveQuiz = require('./kstarlive-quiz');
const kStarCoin = require('./kstar-coin');

const router = (app) => {
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: true }));

  app.get("/", (req, res) => {
    res.status(200).send("Welcome to out restful API");
  });

  app.use('/kstarlive-quiz', kStarLiveQuiz);
  app.use('/kstar-coin', kStarCoin);
}

module.exports = router;
