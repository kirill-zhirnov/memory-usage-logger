memory-usage-logger
===================

This module logs memory usage in CSV file and builds a chart.

The example of a result is:

![Chart example](/examples/screen.jpg?raw=true)

## How to use it?
``` node
var logger = require('memory-usage-logger');

// will log into folder "/absolute/path/to/logs/directory" every 1000 ms:
logger.run(1000, "/absolute/path/to/logs/directory");

// to stop:
logger.stop();
```

## API

### run
``` node
logger.run(delay, logDir)
```
**delay** - delay for **setInterval**
**logDir** - **Directory** to log data.

### stop
``` node
logger.stop()
```
will stop logger which was wun by logger.run().

### setLogDir
``` node
logger.setLogDir('/absolute/path/to/logs/directory')
```
You can also set log directory by calling this func.

### setMaxLogSize
``` node
logger.setMaxLogSize(50000)
```
Set maximum size of CSV file. It useful, since browsers cannot process big data.