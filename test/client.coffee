assert = require('chai').assert
client = require '../src/client'

describe 'Client scripts', ->
	it 'should parse csv string', ->
		str = """1419015368172;26136576;16571136;6312632
1419015368377;26464256;17603072;6612672

"""
		assert.deepEqual client.parseCsv(str), [
			['1419015368172', '26136576', '16571136', '6312632'],
			['1419015368377', '26464256', '17603072', '6612672'],
		]

	it 'prepareSeries should prepare series for Charts', ->
		csvArr =  [
			['1419015368172', '26136576', '16571136', '6312632'],
			['1419015368377', '26464256', '17603072', '6612672'],
		]

		assert.deepEqual client.prepareSeries(csvArr), {
			rss :
				[
					[1419015368172, 26136576]
					[1419015368377, 26464256]
				]

			heapTotal :
				[
					[1419015368172, 16571136]
					[1419015368377, 17603072]
				]

			heapUsed :
				[
					[1419015368172, 6312632]
					[1419015368377, 6612672]
				]
		}
