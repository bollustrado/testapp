const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200);
  res.end('Hello PM2!');
});
server.listen(3001);
