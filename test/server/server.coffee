"use strict"

express = require("express")

server  = module.exports = express()
port    = process.env.PORT or 7777

server.use '/', express.static process.env.DIRECTORY

server.listen port, () ->
	console.log 'Started up test server on port ' + port