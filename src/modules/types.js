// Generated by CoffeeScript 1.3.3
(function() {
  var getType, kinds,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  kinds = {
    simple: ['string', 'number', 'boolean', 'function'],
    composite: ['object', 'array', 'complex array'],
    empty: ['empty array', 'null', 'undefined']
  };

  getType = function(val, options) {
    var complex, el, k, pure, t, type, types, v, _i, _len;
    options = options || {};
    type = typeof val;
    if (type === 'object') {
      if (!(val != null)) {
        return 'null';
      } else {
        if (Array.isArray(val)) {
          complex = false;
          pure = true;
          types = [];
          for (_i = 0, _len = val.length; _i < _len; _i++) {
            el = val[_i];
            t = getType(el);
            if (__indexOf.call(types, t) < 0) {
              if (__indexOf.call(kinds.composite, t) >= 0) {
                complex = true;
              }
              if (t !== 'object') {
                pure = false;
              }
              types.push(t);
            }
          }
          if (types.length === 0) {
            return 'empty array';
          } else {
            if (options.pure) {
              if (pure) {
                return 'purely complex array';
              } else {
                if (complex) {
                  return 'complex array';
                } else {
                  return 'array';
                }
              }
            } else {
              if (complex) {
                return 'complex array';
              } else {
                return 'array';
              }
            }
          }
        } else {
          if (options.pure) {
            complex = false;
            pure = true;
            for (k in val) {
              v = val[k];
              t = getType(v);
              if (__indexOf.call(kinds.composite, t) >= 0) {
                complex = true;
              }
              if (t !== 'object') {
                pure = false;
              }
            }
            if (options.pure) {
              if (pure) {
                return 'purely complex object';
              } else {
                if (complex) {
                  return 'complex object';
                } else {
                  return 'object';
                }
              }
            } else {
              if (complex) {
                return 'complex object';
              } else {
                return 'object';
              }
            }
          } else {
            return 'object';
          }
        }
      }
    } else {
      return type;
    }
  };

  exports.isSimple = function(val) {
    return __indexOf.call(kinds.simple, val) >= 0;
  };

  exports.isComposite = function(val) {
    return __indexOf.call(kinds.composite, val) >= 0;
  };

  exports.kinds = kinds;

  exports.getType = getType;

}).call(this);
