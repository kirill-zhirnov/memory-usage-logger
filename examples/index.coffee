logger = require '../index'
logger.run(1000, "#{__dirname}/logs")

class Request
	constructor : ->
		@bigData = new Array(1e6).join('*')

setInterval ->
	request = new Request
