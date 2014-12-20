assert = require('chai').assert
sinon = require 'sinon'
fs = require 'fs'
MemoryLogger = require '../src/logger'

describe 'MemoryLogger', ->
	fsMock = null
	logger = null
	mockFolderName = "2010-06-01 10:05:05:6"

	beforeEach ->
		logger = new MemoryLogger
		logger.getDate = ->
			return new Date(2010, 5, 1, 10, 5, 5, 6)

		logger.getMemory = ->
			return {
				rss : 10
				heapTotal : 20
				heapUsed : 30
			}

		fsMock = sinon.mock fs

	afterEach ->
		fsMock.restore()

	it 'setLogDir should validate path and set it', ->
		fsMock.expects('existsSync').once().returns(true).withExactArgs(__dirname)

		fsMock.expects('statSync').once().returns({
			isDirectory : ->
				return true
		}).withExactArgs(__dirname)


		logger.setLogDir __dirname

		fsMock.verify()

	it 'serLogDir should thrown Error if path is not valid', ->
#		path does not exist
		fsMock.expects('existsSync').returns(false)

		assert.throws ->
			logger.setLogDir 'aaa'
		, Error, "Directory 'aaa' does not exist!"

#		path is not a directory
		fsMock.expects('existsSync').returns(true)
		fsMock.expects('statSync').returns({
			isDirectory : ->
				return false
		})

		assert.throws ->
			logger.setLogDir 'bbb'
		, Error, "'bbb' is not a directory!"

	it 'prependZero should prepend string if < 10', ->
		assert.equal logger.prependZero(9), '09'
		assert.equal logger.prependZero(1), '01'
		assert.equal logger.prependZero(10), 10

	it 'getFolderName should generate name', ->
		assert.equal logger.getFolderName(), mockFolderName

	it 'initLogFiles should init folder and files', ->
		fsMock.expects('mkdirSync').twice().withExactArgs("some/path/#{mockFolderName}")
		fsMock.expects('existsSync').once().returns(true)
		fsMock.expects('statSync').returns({
			isDirectory : ->
				return true
		})
		fsMock.expects('createReadStream').exactly(4).returns({
			pipe : ->
		})
		fsMock.expects('createWriteStream').exactly(4)

		logger.setLogDir('some/path')

		assert.equal logger.initLogFiles(), "some/path/#{mockFolderName}/data.csv"
		assert.equal logger.getLogFile(), "some/path/#{mockFolderName}/data.csv"

		fsMock.verify()

	it 'appendToLogFile should append string to logFile', ->
		logger.getLogFile = ->
			return 'fileName'

		fsMock.expects('appendFileSync').once().withExactArgs(
			'fileName',
			"#{logger.getDate().getTime()};10;20;30\n",
			{encoding : 'utf8'}
		)

		logger.appendToLogFile()
		fsMock.verify()

	it 'getLogFile should create new folder if size > @maxLogSize', ->
		fsMock.expects('mkdirSync').twice().withExactArgs("some/path/#{mockFolderName}")
		fsMock.expects('existsSync').returns(true)
		fsMock.expects('statSync').returns({
			isDirectory : ->
				return true
			size : 60000
		})
		fsMock.expects('createReadStream').exactly(4).returns({
			pipe : ->
		})
		fsMock.expects('createWriteStream').exactly(4)


		logger.setLogDir 'some/path'
		logger.setMaxLogSize 50000

		assert.equal logger.initLogFiles(), "some/path/#{mockFolderName}/data.csv"
		assert.equal logger.initLogFiles(), "some/path/#{mockFolderName}/data.csv"

		fsMock.verify()

