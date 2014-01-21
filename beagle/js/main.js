// Generated by CoffeeScript 1.6.3
var execute, seq_n, sequence,
  _this = this;

global.rw = require("./rw");

rw.set_emulated(false);

global.Dsc = require("./stepper");

global.c = Dsc.create();

c.set_step_resolution(2, 4);

seq_n = 0;

sequence = [
  {
    act: "rotate",
    dir: "right",
    n: 10
  }, {
    act: "rotate",
    dir: "left",
    n: 10
  }, {
    act: "move",
    dir: "forward",
    n: 10
  }, {
    act: "move",
    dir: "back",
    n: 10
  }
];

execute = function() {
  var step;
  if (seq_n >= sequence.length) {
    return;
  }
  step = sequence[seq_n];
  seq_n++;
  if (step.act === "rotate") {
    return c.rotate(step.dir, step.n, execute);
  } else {
    return c.move(step.dir, step.n, execute);
  }
};

console.log("done");
