/*
post, get route 정의한 후 routes.js에 추가할 것

server_address/newroute 로 들어오는 요청은
newRoute에서 처리하도록 연결

const newRoute = require('./new_route');

const appRouter = (app) => {
  app.use('/newroute', newRoute);
}
*/
const express = require('express');
const router = express.Router();

router.post('/', (req, res) => {
  res.send('POST Response');
});

router.get('/', (req, res) => {
  res.send('GET Response');
});

module.exports = router
