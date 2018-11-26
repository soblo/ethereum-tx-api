const express = require('express');
const routes = require('./routes/index.js');
const app = express();
const PORT = 4601;
const HOST = '0.0.0.0';

routes(app);

app.listen(PORT, HOST, () => console.log(`App listening on ${HOST}:${PORT}`));
