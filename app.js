var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.send('Hello World!');
});

if (require.main === module) {
  app.listen(8080, function () {
    console.log('server running on port 8080');
  });
}

module.exports = app;