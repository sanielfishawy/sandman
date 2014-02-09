class Pin
    
  # direction: "in", "out"
  constructor: (direction, gpio_num) ->
    @config = require("./config")
    @sh = require("execSync")
    @fs = require("fs")
    
    throw "Pin constructor requires (direction, gpio_num)" unless typeof direction is "string" and typeof gpio_num is "number"
    @direction = direction
    @gpio_num = gpio_num
    
    @pin_path = "/sys/class/gpio/gpio" + @gpio_num
      
    @init_pin()
    
  init_pin: => 
    @export()
    @set_direction()
    @open_value_files()
  
  export: (callback) => 
    unless @fs.existsSync("/sys/class/gpio/gpio#{@gpio_num}")
      @run_cmd("echo #{@gpio_num} > /sys/class/gpio/export")
    
  set_direction: (d) => 
    d ||= @direction
    @run_cmd("echo #{d} > #{@pin_path}/direction")
  
  open_value_files: => 
    return if @config.emulated
    path = "#{@pin_path}/value"
    @val_w = @fs.openSync(path, "w")
    @val_r = @fs.openSync(path, "r")
     
  set_val: (v) => 
    return if @config.emulated
    v = v.toString()
    write_buffer = new Buffer(v)
    path = "#{@pin_path}/value"
    @fs.writeSync(@val_w, write_buffer, 0, write_buffer.length, null)
    
  get_val: =>
      
  run_cmd: (cmd) => @sh.run cmd unless @config.emulated
  
create = (direction, gpio_num) => new Pin(direction, gpio_num)

module.exports ={
  create: create
}