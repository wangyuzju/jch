// Generated by CoffeeScript 1.6.3
(function() {
  var LOG_INFO, MD5, cache, exec, fs, pub, stack;

  fs = require('fs');

  MD5 = require('MD5');

  exec = (require('child_process')).exec;

  LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t";

  stack = {};

  cache = {
    _findMatchContent: function(origin, id) {
      var match, regStr;
      regStr = "\\/\\*_JCH_" + (id.replace('/', '\\/')) + "[\\w\\W]*?\\/\\*_JCH_\\*\\/[\\n]?";
      match = origin.match(new RegExp(regStr));
      if (match) {
        return match[0];
      } else {
        return false;
      }
    },
    _read: function(fileName, id) {
      var err, match, origin;
      try {
        origin = fs.readFileSync(fileName, {
          encoding: 'utf8'
        });
        match = this._findMatchContent(origin, id);
        return match;
      } catch (_error) {
        err = _error;
        return false;
      }
    },
    load: function(fileName, id, targetFileName) {
      if (!stack[fileName]) {
        stack[fileName] = {};
      }
      return stack[fileName][id] = this._read(targetFileName, id);
    },
    get: function(fileName, id, targetFileName) {
      var target;
      if (id === 'html') {
        if (!stack[fileName]) {
          stack[fileName] = {};
        }
        if (stack[fileName]['html']) {
          return stack[fileName]['html'];
        }
        return stack[fileName]['html'] = fs.readFileSync(targetFileName, {
          encoding: 'utf8'
        });
      }
      if ((target = stack[fileName])) {
        if (target[id]) {
          return target[id];
        }
      }
      return this.load(fileName, id, targetFileName);
    },
    update: function(fileName, id, newContent) {
      return stack[fileName][id] = newContent;
    }
  };

  pub = {
    _genContent: function(id, origin, strToAdd) {
      var find, regStr, res;
      regStr = "\\/\\*_JCH_" + (id.replace('/', '\\/')) + "[\\w\\W]*?\\/\\*_JCH_\\*\\/[\\n]?";
      find = false;
      res = origin.replace(new RegExp(regStr, 'g'), function(match, p1) {
        if (!find) {
          find = true;
          return strToAdd;
        } else {
          return "";
        }
      });
      if (find) {
        return res;
      } else {
        return false;
      }
    },
    _append: function(fp, s) {
      fs.appendFileSync(fp, s);
    },
    _write: function(fp, s) {
      return fs.writeFileSync(fp, s);
    },
    target: {},
    insert: function(strToAdd, opts) {
      var err, oContent, origin, res;
      oContent = cache.get(opts.fileName, opts.id, opts.target);
      if (strToAdd === oContent) {

      } else {
        console.log("" + LOG_INFO + "[Insert] " + opts.target);
        try {
          origin = fs.readFileSync(opts.target, {
            encoding: 'utf8'
          });
          res = this._genContent(opts.id, origin, strToAdd);
          if (res) {
            this._write(opts.target, res);
          } else {
            this._append(opts.target, strToAdd);
          }
        } catch (_error) {
          err = _error;
          this._write(opts.target, strToAdd);
        }
        return cache.update(opts.fileName, opts.id, strToAdd);
      }
    },
    save: function(fileName, target, content) {
      var oContent;
      oContent = cache.get(fileName, 'html', target);
      if (content === oContent) {

      } else {
        if (fs.existsSync(target)) {
          if (content === "") {
            exec("rm " + target, function(err, stdout, stderr) {
              if (err) {
                return console.error("" + LOG_INFO + "[HTML][D] " + err);
              } else {
                return console.log("" + LOG_INFO + "[HTML][D] " + target);
              }
            });
          } else {
            this._write(target, content);
          }
        } else {
          if (content !== "") {
            this._write(target, content);
            console.log("" + LOG_INFO + "[HTML][C] " + target);
          }
        }
        return cache.update(fileName, 'html', content);
      }
    }
  };

  module.exports = pub;

}).call(this);