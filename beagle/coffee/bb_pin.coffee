class Pin
  
  # direction: "in", "out"
  constructor: (direction, gpio_num) ->
    throw "Pin constructor requires (direction, gpio_num)" unless typeof direction is "string" and typeof gpio_num is "number"
    @direction = direction
    @gpio_num = gpio_num
    
    @sh = require("/usr/lib/node_modules/execSync")
    @fs = require("fs")
    @pin_path = "/sys/class/gpio/gpio" + @gpio_num
      
    @init_pin()
    
  init_pin: => 
    @export()
    @set_direction()
  
  export: (callback) => 
    unless @fs.existsSync("/sys/class/gpio/gpio#{@gpio_num}")
      @sh.run("echo #{@gpio_num} > /sys/class/gpio/export")
    
  set_direction: (d) => 
    d ||= @direction
    @sh.run("echo #{d} > #{@pin_path}/direction")
  
  set_val: (v) => 
    cmd = "echo #{v} > #{@pin_path}/value"
    @sh.run cmd
    
  get_val: =>


create = (direction, gpio_num) => new Pin(direction, gpio_num)

module.exports ={
  create: create
}