// Generated by CoffeeScript 1.6.3
var DualStepperController, DualStepperDriver, Stepper, StepperDeviceOverlay, create, exec, sh,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  _this = this;

sh = require("execSync");

exec = require('child_process').exec;

DualStepperController = (function() {
  function DualStepperController() {
    this.delegate_methods = __bind(this.delegate_methods, this);
    this.set_rpm = __bind(this.set_rpm, this);
    this.hello = __bind(this.hello, this);
    this.step = __bind(this.step, this);
    this.move = __bind(this.move, this);
    this.rotate = __bind(this.rotate, this);
    this.c_name = "DualStepperController";
    this.sdo = StepperDeviceOverlay;
    this.sdo.install();
    this.dsd = DualStepperDriver;
    this.dsd.init();
    this.delegate_methods();
  }

  DualStepperController.prototype.rotate = function(dir, n, callback) {
    console.log("Rotate " + dir + " n:" + n);
    if (parseInt(dir) < 0 || (typeof dir === "string" && dir[0].toLowerCase() === "l")) {
      return this.step("back", "forward", n, callback);
    } else {
      return this.step("forward", "back", n, callback);
    }
  };

  DualStepperController.prototype.move = function(dir, n, callback) {
    console.log("Move " + dir + " n:" + n);
    if (parseInt(dir) < 0 || (typeof dir === "string" && dir[0].toLowerCase() === "b")) {
      return this.step("back", "back", n, callback);
    } else {
      return this.step("forward", "forward", n, callback);
    }
  };

  DualStepperController.prototype.step = function(m0_dir, m1_dir, n, callback) {
    this.dsd.set_direction(m0_dir, m1_dir);
    return this.dsd.step_n(2, n, callback);
  };

  DualStepperController.prototype.hello = function(val, callback) {
    console.log("DualStepperController: hello - " + val);
    return callback({
      hello: "world"
    });
  };

  DualStepperController.prototype.set_rpm = function(val, callback) {
    this.dsd.rpm = parseInt(val);
    if (callback) {
      return callback({
        msg: "" + this.c_name + ".set_rpm: " + val + " done."
      });
    }
  };

  DualStepperController.prototype.delegate_methods = function() {
    this.rot = this.rotate;
    this.stop = this.dsd.stop;
    this.set_step_resolution = this.dsd.set_step_resolution;
    this.sleep = this.dsd.sleep;
    return this.wake = this.dsd.wake;
  };

  return DualStepperController;

})();

StepperDeviceOverlay = (function() {
  function StepperDeviceOverlay() {}

  StepperDeviceOverlay.c_name = "StepperDeviceOverlay";

  StepperDeviceOverlay.package_name = "ED-Stepper";

  StepperDeviceOverlay.slots = "/sys/devices/bone_capemgr.8/slots";

  StepperDeviceOverlay.uninstall = function() {
    var slot_num;
    if (StepperDeviceOverlay.is_installed()) {
      slot_num = StepperDeviceOverlay.get_slot_num();
      console.log("" + StepperDeviceOverlay.c_name + ".uninstall: uninstalling " + StepperDeviceOverlay.package_name + " from slot: " + slot_num);
      sh.run("echo -" + slot_num + " > " + StepperDeviceOverlay.slots);
    } else {
      console.log("" + StepperDeviceOverlay.c_name + ".uninstall: " + StepperDeviceOverlay.package_name + " not installed.");
    }
    if (StepperDeviceOverlay.is_installed()) {
      throw "" + StepperDeviceOverlay.c_name + ".uninstall: Error " + StepperDeviceOverlay.package_name + " still installed";
    }
  };

  StepperDeviceOverlay.install = function() {
    if (StepperDeviceOverlay.is_installed()) {
      console.log("" + StepperDeviceOverlay.c_name + ".install: already installed. Not installing again.");
    } else {
      console.log("" + StepperDeviceOverlay.c_name + ".install: installing device overlay: " + StepperDeviceOverlay.package_name + ".");
      sh.run("echo " + StepperDeviceOverlay.package_name + " > " + StepperDeviceOverlay.slots);
    }
    return console.log("" + StepperDeviceOverlay.c_name + ".install: " + StepperDeviceOverlay.package_name + " device overlay installed = " + (StepperDeviceOverlay.is_installed()) + ". Slot_num=" + (StepperDeviceOverlay.get_slot_num()));
  };

  StepperDeviceOverlay.is_installed = function() {
    return StepperDeviceOverlay.get_slot() !== "";
  };

  StepperDeviceOverlay.get_slot = function() {
    var result;
    result = sh.exec("cat " + StepperDeviceOverlay.slots + " | grep " + StepperDeviceOverlay.package_name);
    return result.stdout;
  };

  StepperDeviceOverlay.get_slot_num = function() {
    return parseInt(StepperDeviceOverlay.get_slot());
  };

  return StepperDeviceOverlay;

}).call(this);

DualStepperDriver = (function() {
  function DualStepperDriver() {}

  DualStepperDriver.c_name = "DualStepperDriver";

  DualStepperDriver.bb_pin = require("./bb_pin");

  DualStepperDriver.rpm = 200;

  DualStepperDriver.pin_nums = [30, 31, 48, 5, 3, 60, 50, 51, 4, 2];

  DualStepperDriver.init = function() {
    return DualStepperDriver.init_pins();
  };

  DualStepperDriver.init_pins = function() {
    var num, _i, _len, _ref;
    DualStepperDriver.pins = {};
    _ref = DualStepperDriver.pin_nums;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      num = _ref[_i];
      DualStepperDriver.pins[num] = DualStepperDriver.bb_pin.create("out", num);
    }
    return DualStepperDriver.pinout = {
      0: {
        "ms1": DualStepperDriver.pins[30],
        "ms2": DualStepperDriver.pins[31],
        "sleep": DualStepperDriver.pins[48],
        "direction": DualStepperDriver.pins[5],
        "step": DualStepperDriver.pins[3]
      },
      1: {
        "ms1": DualStepperDriver.pins[60],
        "ms2": DualStepperDriver.pins[50],
        "sleep": DualStepperDriver.pins[51],
        "direction": DualStepperDriver.pins[4],
        "step": DualStepperDriver.pins[2]
      }
    };
  };

  DualStepperDriver.pinout_for_motor = function(n) {
    return DualStepperDriver.pinout[n];
  };

  DualStepperDriver.get_motors_from_m_n = function(m_n) {
    m_n = parseInt(m_n);
    switch (m_n) {
      case 0:
        return [0];
      case 1:
        return [1];
      case 2:
      case "both":
        return [0, 1];
      default:
        return [];
    }
  };

  DualStepperDriver.set_step_resolution = function(m_n, res, callback) {
    var m_num, motors, _i, _j, _k, _l, _len, _len1, _len2, _len3;
    res += "";
    res = res[0].toLowerCase();
    motors = DualStepperDriver.get_motors_from_m_n(m_n);
    console.log(motors);
    switch (res) {
      case "full"[0]:
      case "1":
        console.log("Setting step resolution to FULL m_n: " + m_n);
        for (_i = 0, _len = motors.length; _i < _len; _i++) {
          m_num = motors[_i];
          DualStepperDriver.set_pin(m_num, "ms1", 0);
          DualStepperDriver.set_pin(m_num, "ms2", 0);
        }
        break;
      case "half"[0]:
      case "2":
        console.log("Setting step resolution to HALF m_n: " + m_n);
        for (_j = 0, _len1 = motors.length; _j < _len1; _j++) {
          m_num = motors[_j];
          DualStepperDriver.set_pin(m_num, "ms1", 0);
          DualStepperDriver.set_pin(m_num, "ms2", 1);
        }
        break;
      case "quarter"[0]:
      case "4":
        console.log("Setting step resolution to QUARTER m_n: " + m_n);
        for (_k = 0, _len2 = motors.length; _k < _len2; _k++) {
          m_num = motors[_k];
          DualStepperDriver.set_pin(m_num, "ms1", 1);
          DualStepperDriver.set_pin(m_num, "ms2", 0);
        }
        break;
      case "eigth"[0]:
      case "8":
        console.log("Setting step resolution to EIGTH m_n: " + m_n);
        for (_l = 0, _len3 = motors.length; _l < _len3; _l++) {
          m_num = motors[_l];
          DualStepperDriver.set_pin(m_num, "ms1", 1);
          DualStepperDriver.set_pin(m_num, "ms2", 1);
        }
    }
    if (callback) {
      return callback({
        msg: "" + DualStepperDriver.c_name + ".set_step_resolution: " + res + " done."
      });
    }
  };

  DualStepperDriver.set_sleep = function(m_n, val) {
    var m_num, _i, _len, _ref, _results;
    _ref = DualStepperDriver.get_motors_from_m_n(m_n);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      m_num = _ref[_i];
      _results.push(DualStepperDriver.set_pin(m_num, "sleep", val));
    }
    return _results;
  };

  DualStepperDriver.sleep = function(m_n, callback) {
    DualStepperDriver.set_sleep(m_n, 1);
    if (callback) {
      return callback({
        msg: "" + DualStepperDriver.c_name + ".sleep: done."
      });
    }
  };

  DualStepperDriver.wake = function(m_n, callback) {
    DualStepperDriver.set_sleep(m_n, 0);
    if (callback) {
      return callback({
        msg: "" + DualStepperDriver.c_name + ".wake: done."
      });
    }
  };

  DualStepperDriver.set_direction = function(m0_dir, m1_dir) {
    var dir, dirs, m_n, _i, _len, _ref, _results;
    console.log("Setting direction m0: " + m0_dir + ",  m1: " + m1_dir);
    dirs = [m0_dir, m1_dir];
    _ref = [0, 1];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      m_n = _ref[_i];
      dir = dirs[m_n];
      switch (dir) {
        case 0:
        case "b":
        case "back":
          _results.push(DualStepperDriver.set_pin(m_n, "direction", 0));
          break;
        case 1:
        case "f":
        case "forward":
          _results.push(DualStepperDriver.set_pin(m_n, "direction", 1));
          break;
        default:
          _results.push(void 0);
      }
    }
    return _results;
  };

  DualStepperDriver.step_n = function(m_n, num_steps, callback) {
    var cmd, m_num, motors, step_pin, _i, _len;
    if (callback == null) {
      callback = function() {};
    }
    DualStepperDriver.stopped = false;
    motors = DualStepperDriver.get_motors_from_m_n(m_n);
    console.log("step_n num_steps = " + num_steps);
    cmd = "pulse_pins " + num_steps + " 700 /sys/class/gpio/gpio";
    for (_i = 0, _len = motors.length; _i < _len; _i++) {
      m_num = motors[_i];
      step_pin = DualStepperDriver.pinout[m_num]["step"];
      cmd += " " + step_pin.gpio_num;
    }
    console.log(cmd);
    DualStepperDriver.step_n_callback = callback;
    return exec(cmd, DualStepperDriver.step_n_done);
  };

  DualStepperDriver.step_n_done = function(error, stdout, stderr) {
    DualStepperDriver.stopped = false;
    if (DualStepperDriver.step_n_callback) {
      return DualStepperDriver.step_n_callback({
        msg: stdout + stderr + " steps"
      });
    }
  };

  DualStepperDriver.step_n_delay = function(m_n, num_steps, callback) {
    DualStepperDriver.stopped = false;
    DualStepperDriver.step_n_remaining = num_steps;
    DualStepperDriver.step_n_num_steps_done = 0;
    DualStepperDriver.step_n_callback = callback;
    DualStepperDriver.step_n_m_n = m_n;
    DualStepperDriver.t0_step_n = new Date;
    return DualStepperDriver.step_timer = setInterval(DualStepperDriver.step_and_count, DualStepperDriver.interval_from_rpm(DualStepperDriver.rpm));
  };

  DualStepperDriver.step_and_count = function() {
    if (DualStepperDriver.stopped) {
      DualStepperDriver.step_and_count_done();
    }
    DualStepperDriver.step(DualStepperDriver.step_n_m_n);
    DualStepperDriver.step_n_remaining--;
    DualStepperDriver.step_n_num_steps_done++;
    if (DualStepperDriver.step_n_remaining === 0) {
      return DualStepperDriver.step_and_count_done();
    }
  };

  DualStepperDriver.step_and_count_done = function() {
    var d_t;
    console.log("step_n done: " + DualStepperDriver.step_n_num_steps_done + " steps");
    if (DualStepperDriver.step_timer) {
      clearInterval(DualStepperDriver.step_timer);
    }
    d_t = (new Date) - DualStepperDriver.t0_step_n;
    console.log("" + DualStepperDriver.c_name + ".step_and_count_done: progRPM=" + DualStepperDriver.rpm + " actualRPM = " + (DualStepperDriver.rpm_from_time_and_steps(d_t, DualStepperDriver.step_n_num_steps_done)));
    DualStepperDriver.stopped = false;
    if (DualStepperDriver.step_n_callback) {
      return DualStepperDriver.step_n_callback({
        num_steps_done: DualStepperDriver.step_n_num_steps_done
      });
    }
  };

  DualStepperDriver.step = function(m_n) {
    var m_num, motors, _i, _len, _results;
    motors = DualStepperDriver.get_motors_from_m_n(m_n);
    _results = [];
    for (_i = 0, _len = motors.length; _i < _len; _i++) {
      m_num = motors[_i];
      DualStepperDriver.set_pin(m_num, "step", 1);
      _results.push(DualStepperDriver.set_pin(m_num, "step", 0));
    }
    return _results;
  };

  DualStepperDriver.stop = function(callback) {
    console.log("Stop message sent");
    DualStepperDriver.stopped = true;
    if (callback) {
      return callback({
        msg: "" + DualStepperDriver.c_name + ".stop: done."
      });
    }
  };

  DualStepperDriver.set_pin = function(m_num, pin_name, val) {
    return DualStepperDriver.pinout[m_num][pin_name].set_val(val);
  };

  DualStepperDriver.interval_from_rpm = function(rpm) {
    var ms_step, rpms, steps_per_ms;
    rpms = rpm / 60000.0;
    steps_per_ms = rpms * 200.0;
    return ms_step = Math.round(1 / steps_per_ms);
  };

  DualStepperDriver.rpm_from_time_and_steps = function(time, steps) {
    var rpm, rpms, steps_per_ms;
    steps_per_ms = 1.0 * steps / time;
    rpms = steps_per_ms / 200;
    return rpm = rpms * 60000;
  };

  return DualStepperDriver;

}).call(this);

Stepper = (function() {
  function Stepper(n) {}

  return Stepper;

})();

create = function() {
  return new DualStepperController;
};

module.exports = {
  create: create
};
