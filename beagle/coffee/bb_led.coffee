RW = require('./rw')

# led_path = "/Users/sani/dev/sandman/sandman/beagle/"
led_path = "/sys/class/leds/beaglebone:green:usr"
  
led_on = (n) -> 
  set_trigger(n, "none")
  RW.write( control_path(n, "brightness"), "1")
  
led_off = (n) -> 
  set_trigger(n, "none")
  RW.write( control_path(n, "brightness"), "0")

set_trigger = (n, trigger) -> RW.write( control_path(n, "trigger"), trigger )

led_state = (n) -> 

control_path = (n, control) -> "#{led_path}#{n}/#{control}"

module.exports = {
  led_on: led_on
  led_off: led_off
  set_trigger: set_trigger
}
