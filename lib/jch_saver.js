// Generated by CoffeeScript 1.6.3
(function() {
    var LOG_INFO, MD5, exec, fs, pub;

    fs = require('fs');

    MD5 = require('MD5');

    exec = (require('child_process')).exec;

    LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t";

    pub = {
        _genContent: function(id, origin, strToAdd) {
            var find, regStr, res;
            regStr = "\\/\\*_JCH_" + (id.replace('/', '\\/')) + "[\\w\\W]*?\\/\\*_JCH_\\*\\/[\\n]?";
            find = false;
            console.log (regStr)
            res = origin.replace(new RegExp(regStr, 'g'), function(match, p1) {
                console.error(match)
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
            var err, origin, res;
            console.log("" + LOG_INFO + "[Insert] " + opts.target);
            try {
                origin = fs.readFileSync(opts.target, {
                    encoding: 'utf8'
                });
                res = this._genContent(opts.id, origin, strToAdd);
                if (res) {
                    return this._write(opts.target, res);
                } else {
                    return this._append(opts.target, strToAdd);
                }
            } catch (_error) {
                err = _error;
                return this._write(opts.target, strToAdd);
            }
        },
        save: function(target, content) {
            if (fs.existsSync(target)) {
                if (content === "") {
                    return exec("rm " + target, function(err, stdout, stderr) {
                        if (err) {
                            return console.error("" + LOG_INFO + "[HTML][D] " + err);
                        } else {
                            return console.log("" + LOG_INFO + "[HTML][D] " + target);
                        }
                    });
                } else {
                    console.error("" + LOG_INFO + "[HTML][S] " + target);
                    return fs.writeFileSync(target, content);
                }
            } else {
                if (content !== "") {
                    fs.writeFileSync(target, content);
                    return console.log("" + LOG_INFO + "[HTML][C] " + target);
                }
            }
        }
    };

    module.exports = pub;

}).call(this);/*_JCH_lib/coffess_saver.coffee_text/coffeescript */
// Generated by CoffeeScript 1.6.3
var LOG_INFO, MD5, exec, fs, pub;

fs = require('fs');

MD5 = require('MD5');

exec = (require('child_process')).exec;

LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t";

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
    var err, origin, res;
    console.log("" + LOG_INFO + "[Insert] " + opts.target);
    try {
      origin = fs.readFileSync(opts.target, {
        encoding: 'utf8'
      });
      res = this._genContent(opts.id, origin, strToAdd);
      if (res) {
        return this._write(opts.target, res);
      } else {
        return this._append(opts.target, strToAdd);
      }
    } catch (_error) {
      err = _error;
      return this._write(opts.target, strToAdd);
    }
  },
  save: function(target, content) {
    if (fs.existsSync(target)) {
      if (content === "") {
        return exec("rm " + target, function(err, stdout, stderr) {
          if (err) {
            return console.error("" + LOG_INFO + "[HTML][D] " + err);
          } else {
            return console.log("" + LOG_INFO + "[HTML][D] " + target);
          }
        });
      } else {
        console.error("" + LOG_INFO + "[HTML][S] " + target);
        return fs.writeFileSync(target, content);
      }
    } else {
      if (content !== "") {
        fs.writeFileSync(target, content);
        return console.log("" + LOG_INFO + "[HTML][C] " + target);
      }
    }
  }
};

module.exports = pub;
/*_JCH_*/
/*_JCH_coffess_saver.coffee_text/coffeescript */
// Generated by CoffeeScript 1.6.3
var LOG_INFO, MD5, exec, fs, pub;

fs = require('fs');

MD5 = require('MD5');

exec = (require('child_process')).exec;

LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t";

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
    var err, origin, res;
    console.log("" + LOG_INFO + "[Insert] " + opts.target);
    try {
      origin = fs.readFileSync(opts.target, {
        encoding: 'utf8'
      });
      res = this._genContent(opts.id, origin, strToAdd);
      if (res) {
        return this._write(opts.target, res);
      } else {
        return this._append(opts.target, strToAdd);
      }
    } catch (_error) {
      err = _error;
      return this._write(opts.target, strToAdd);
    }
  },
  save: function(target, content) {
    if (fs.existsSync(target)) {
      if (content === "") {
        return exec("rm " + target, function(err, stdout, stderr) {
          if (err) {
            return console.error("" + LOG_INFO + "[HTML][D] " + err);
          } else {
            return console.log("" + LOG_INFO + "[HTML][D] " + target);
          }
        });
      } else {
        console.error("" + LOG_INFO + "[HTML][S] " + target);
        return fs.writeFileSync(target, content);
      }
    } else {
      if (content !== "") {
        fs.writeFileSync(target, content);
        return console.log("" + LOG_INFO + "[HTML][C] " + target);
      }
    }
  }
};

module.exports = pub;
/*_JCH_*/
