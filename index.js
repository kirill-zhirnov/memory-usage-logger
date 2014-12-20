var MemoryLogger = require('./lib/logger'),
	logger = new MemoryLogger();

var exportMethods = [
	'run',
	'stop',
	'setLogDir',
	'setMaxLogSize'
];

for (var i = 0; i < exportMethods.length; i++) {
	(function(method) {
		module.exports[method] = function() {
			return logger[method].apply(logger, arguments);
		};
	}) (exportMethods[i]);
}
