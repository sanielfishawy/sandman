// Generated by CoffeeScript 1.6.3
var __slice = [].slice;

String.prototype.capitalize_words = function() {
  return this.toLowerCase().replace(/^.|\s\S/g, function(a) {
    return a.toUpperCase();
  });
};

String.prototype.is_email = function() {
  var regex;
  regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return regex.test(this);
};

String.prototype.is_phone = function() {
  return this.replace(/[^+\d]/g, "").length >= 10;
};

String.prototype.trim_phone = function() {
  return this.replace(/[^+\d]/g, "");
};

String.prototype.initial = function() {
  if (this.length > 0) {
    return "" + (this[0].toUpperCase());
  } else {
    return "";
  }
};

String.prototype.briefly = function(l) {
  if (this.length <= l) {
    return this.toString();
  } else {
    return this.slice(0, +(l - 1) + 1 || 9e9) + "&hellip;";
  }
};

String.prototype.truncate = function(l) {
  if (this.length <= l) {
    return this.toString();
  } else {
    return this.slice(0, +(l - 1) + 1 || 9e9);
  }
};

String.prototype.escape_html = function() {
  var chr;
  chr = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;',
    "/": '&#x2F;'
  };
  return String(this).replace(/[&<>"'\/]/g, function(s) {
    return chr[s];
  });
};

String.prototype.strip_vertical_space = function() {
  return String(this).replace(/[\r\n\v\f]+/g, " ");
};

String.prototype.trim = function() {
  return String(this).replace(/^\s+/, "").replace(/\s+$/, "");
};

String.prototype.is_blank = function() {
  return String(this) === "";
};

Number.prototype.to_rad = function() {
  return this * Math.PI / 180.0;
};

Number.prototype.to_deg = function() {
  return this * 180.0 / Math.PI;
};

Number.prototype.pos_deg = function() {
  if (this < 0) {
    return 360 + (this % 360);
  } else {
    return this % 360;
  }
};

Array.prototype.is_blank = function() {
  return this.length === 0;
};

Array.prototype.minus = function(b) {
  return this.filter(function(a) {
    return b.indexOf(a) === -1;
  });
};

Array.prototype.intersect = function(b) {
  return this.filter(function(a) {
    return b.indexOf(a) > -1;
  });
};

Array.prototype.max = function() {
  return Math.max.apply(Math, this);
};

Array.prototype.min = function() {
  return Math.min.apply(Math, this);
};

Array.prototype.sum = function() {
  var n, sum, _i, _len;
  sum = 0;
  for (_i = 0, _len = this.length; _i < _len; _i++) {
    n = this[_i];
    sum += n;
  }
  return sum;
};

Array.prototype.mean = function() {
  return this.sum() / this.length;
};

Array.prototype.average = function() {
  return this.mean();
};

Array.prototype.last = function(n) {
  if (n == null) {
    n = 1;
  }
  if (this.length === 0 && n === 1) {
    return null;
  }
  n = n > this.length ? this.length : n;
  if (n === 1) {
    return this[this.length - 1];
  } else {
    return this.slice(this.length - n, +(this.length - 1) + 1 || 9e9);
  }
};

Array.prototype.first = function(n) {
  if (n == null) {
    n = 1;
  }
  if (this.length === 0 && n === 1) {
    return null;
  }
  if (n < 0) {
    return this;
  }
  if (n === 1) {
    return this[0];
  } else {
    return this.slice(0, +(n - 1) + 1 || 9e9);
  }
};

Array.prototype.longest_word = function() {
  return this.sort(function(a, b) {
    return b.length - a.length;
  })[0];
};

Array.prototype.shortest_word = function() {
  return this.sort(function(a, b) {
    return a.length - b.length;
  })[0];
};

Array.prototype.includes = function(el) {
  var mem, _i, _len;
  for (_i = 0, _len = this.length; _i < _len; _i++) {
    mem = this[_i];
    if (el === mem) {
      return true;
    }
  }
  return false;
};

Array.prototype.remove = function() {
  var arg, args, index, output, _i, _len;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  output = [];
  for (_i = 0, _len = args.length; _i < _len; _i++) {
    arg = args[_i];
    index = this.indexOf(arg);
    if (index !== -1) {
      output.push(this.splice(index, 1));
    }
  }
  if (args.length === 1) {
    output = output[0];
  }
  return output;
};

Array.prototype.to_sentence = function() {
  if (this.length === 0) {
    return "";
  } else if (this.length === 1) {
    return this[0].toString();
  } else if (this.length === 2) {
    return this[0].toString() + " and " + this[1].toString();
  } else {
    return this.slice(0, this.length - 1).join(", ") + ", and " + this[this.length - 1];
  }
};

Array.prototype.uniq = function() {
  var el, h, _fn, _i, _len;
  h = {};
  _fn = function() {
    return h[el] = true;
  };
  for (_i = 0, _len = this.length; _i < _len; _i++) {
    el = this[_i];
    _fn();
  }
  return keys(h);
};
