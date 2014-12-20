(function() {
  var MemoryLogger, fs;

  fs = require('fs');

  MemoryLogger = (function() {
    function MemoryLogger() {
      this.logDir = null;
      this.logFile = null;
      this.interval = null;
      this.maxLogSize = 50000;
    }

    MemoryLogger.prototype.run = function(delay, logDir) {
      if (delay == null) {
        delay = 1000;
      }
      if (logDir == null) {
        logDir = null;
      }
      if (logDir != null) {
        this.setLogDir(logDir);
      }
      this.interval = setInterval((function(_this) {
        return function() {
          return _this.appendToLogFile();
        };
      })(this), delay);
      return this;
    };

    MemoryLogger.prototype.stop = function() {
      clearInterval(this.interval);
      return this;
    };

    MemoryLogger.prototype.appendToLogFile = function(event) {
      var columns, memory, str;
      if (event == null) {
        event = null;
      }
      memory = this.getMemory();
      columns = [this.getDate().getTime()];
      columns.push(memory.rss);
      columns.push(memory.heapTotal);
      columns.push(memory.heapUsed);
      str = "" + (columns.join(';')) + "\n";
      return fs.appendFileSync(this.getLogFile(), str, {
        encoding: 'utf8'
      });
    };

    MemoryLogger.prototype.setLogDir = function(logDir) {
      if (!fs.existsSync(logDir)) {
        throw new Error("Directory '" + logDir + "' does not exist!");
      }
      if (!fs.statSync(logDir).isDirectory()) {
        throw new Error("'" + logDir + "' is not a directory!");
      }
      this.logDir = logDir;
      return this;
    };

    MemoryLogger.prototype.getLogFile = function() {
      if (this.logFile == null) {
        this.logFile = this.initLogFiles();
      } else {
        if (fs.statSync(this.logFile).size > this.maxLogSize) {
          this.logFile = this.initLogFiles();
        }
      }
      return this.logFile;
    };

    MemoryLogger.prototype.initLogFiles = function() {
      var folder;
      if (this.logDir == null) {
        throw new Error("You should setup logDir before calling this method!");
      }
      folder = "" + this.logDir + "/" + (this.getFolderName());
      fs.mkdirSync(folder);
      fs.createReadStream('../src/index.html').pipe(fs.createWriteStream("" + folder + "/index.html"));
      fs.createReadStream('../lib/client.js').pipe(fs.createWriteStream("" + folder + "/client.js"));
      return "" + folder + "/data.csv";
    };

    MemoryLogger.prototype.prependZero = function(number) {
      if (number < 10) {
        return '0' + number;
      } else {
        return number;
      }
    };

    MemoryLogger.prototype.getFolderName = function() {
      var date, day, hour, minutes, month, sec;
      date = this.getDate();
      month = this.prependZero(date.getMonth() + 1);
      day = this.prependZero(date.getDate());
      hour = this.prependZero(date.getHours());
      minutes = this.prependZero(date.getMinutes());
      sec = this.prependZero(date.getSeconds());
      return "" + (date.getFullYear()) + "-" + month + "-" + day + " " + hour + ":" + minutes + ":" + sec + ":" + (date.getMilliseconds());
    };

    MemoryLogger.prototype.getDate = function() {
      return new Date;
    };

    MemoryLogger.prototype.getMemory = function() {
      return process.memoryUsage();
    };

    MemoryLogger.prototype.setMaxLogSize = function(maxLogSize) {
      this.maxLogSize = maxLogSize;
      return this;
    };

    return MemoryLogger;

  })();

  module.exports = MemoryLogger;

}).call(this);
