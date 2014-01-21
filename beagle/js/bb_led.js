// Generated by CoffeeScript 1.6.3
var RW, control_path, led_off, led_on, led_path, led_state, set_trigger;

RW = require('./rw');

led_path = "/sys/class/leds/beaglebone:green:usr";

led_on = function(n) {
  set_trigger(n, "none");
  return RW.write(control_path(n, "brightness"), "1");
};

led_off = function(n) {
  set_trigger(n, "none");
  return RW.write(control_path(n, "brightness"), "0");
};

set_trigger = function(n, trigger) {
  return RW.write(control_path(n, "trigger"), trigger);
};

led_state = function(n) {};

control_path = function(n, control) {
  return "" + led_path + n + "/" + control;
};

module.exports = {
  led_on: led_on,
  led_off: led_off,
  set_trigger: set_trigger
};
