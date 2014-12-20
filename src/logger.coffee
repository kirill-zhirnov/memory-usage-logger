fs = require 'fs'

class MemoryLogger
	constructor : () ->
#		where to save log
		@logDir = null
		@logFile = null

		@interval = null
		@maxLogSize = 50000

#	logDir - should be absolute path
	run : (delay = 1000, logDir = null) ->
		if logDir?
			@setLogDir logDir

		@interval = setInterval =>
			@appendToLogFile()
		, delay

		return @

	stop : ->
		clearInterval @interval

		return @

	appendToLogFile : (event = null) ->
		memory = @getMemory()

		columns = [@getDate().getTime()]
		columns.push memory.rss
		columns.push memory.heapTotal
		columns.push memory.heapUsed

		str = "#{columns.join(';')}\n"
		fs.appendFileSync @getLogFile(), str, {
			encoding : 'utf8'
		}

	setLogDir : (logDir) ->
		if !fs.existsSync(logDir)
			 throw new Error "Directory '#{logDir}' does not exist!"

		if not fs.statSync(logDir).isDirectory()
			throw new Error "'#{logDir}' is not a directory!"

		@logDir = logDir

		return @

	getLogFile : ->
		if not @logFile?
			@logFile = @initLogFiles()
		else
			if fs.statSync(@logFile).size > @maxLogSize
				@logFile = @initLogFiles()

		return @logFile

	initLogFiles : ->
		if not @logDir?
			throw new Error "You should setup logDir before calling this method!"

		folder = "#{@logDir}/#{@getFolderName()}"

		fs.mkdirSync folder

		fs.createReadStream('../src/index.html').pipe(fs.createWriteStream("#{folder}/index.html"))
		fs.createReadStream('../lib/client.js').pipe(fs.createWriteStream("#{folder}/client.js"))

		return "#{folder}/data.csv"

	prependZero : (number) ->
		return if number < 10 then '0' + number else number

	getFolderName : ->
		date = @getDate()

		month = @prependZero date.getMonth() + 1
		day = @prependZero date.getDate()
		hour = @prependZero date.getHours()
		minutes = @prependZero date.getMinutes()
		sec = @prependZero date.getSeconds()

		return "#{date.getFullYear()}-#{month}-#{day} #{hour}:#{minutes}:#{sec}:#{date.getMilliseconds()}"

	getDate : () ->
		return new Date

	getMemory : () ->
		return process.memoryUsage()

	setMaxLogSize : (@maxLogSize) ->
		return @

module.exports = MemoryLogger
