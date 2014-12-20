parseCsv = (str) ->
	rows = str.split "\n"

	out = []
	for val, key in rows
		if not val.length
			continue

		out.push val.split(";")

	return out

prepareSeries = (csvArr) ->
	out = {
		rss : []
		heapTotal : []
		heapUsed : []
	}

	for row in csvArr
		ts = row[0] * 1
		rss = row[1] * 1
		heapTotal = row[2] * 1
		heapUsed = row[3] * 1

		out.rss.push [ts, rss]
		out.heapTotal.push [ts, heapTotal]
		out.heapUsed.push [ts, heapUsed]

	return out

getChartConfig = (csvStr) ->
	return {
		rangeSelector :
			selected : 1

		title :
			text : 'Memory usage'

		series : []

		tooltip:
			pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> bytes<br/>',
			valueDecimals: 0
	}

run = () ->
	$.get './data.csv', {}, (csvStr) ->
		data = prepareSeries parseCsv(csvStr)
		chartConfig = getChartConfig()

		chartConfig.series.push({
			name: 'rss'
			data: data.rss
		})

		chartConfig.series.push({
			name: 'heapTotal'
			data: data.heapTotal
		})

		chartConfig.series.push({
			name: 'heapUsed'
			data: data.heapUsed
		})

		$('#container').highcharts 'StockChart', chartConfig
	, 'html'

	return

#	export to client

# it needs for tests.
module.exports.parseCsv = parseCsv
module.exports.prepareSeries = prepareSeries
module.exports.getChartConfig = getChartConfig
module.exports.run = run