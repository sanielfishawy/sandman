rw = require("./rw")
sh = require("/usr/lib/node_modules/execSync")

# =========================
# = DualStepperController =
# =========================
class DualStepperController
  
  constructor: -> 
    @sdo = StepperDeviceOverlay
    @sdo.install()
    @dsd = DualStepperDriver
    @dsd.init()
    
    @delegate_methods()
  
  rotate: (dir, n, callback) =>
    console.log "Rotate #{dir} n:#{n}" 
    if parseInt(dir) < 0 or dir[0].toLowerCase() is "l"
      @step("back", "forward", n, callback)
    else
      @step("forward", "back", n, callback)
  
  move: (dir, n, callback) => 
    console.log "Move #{dir} n:#{n}" 
    if parseInt(dir) < 0 or dir[0].toLowerCase() is "b"
      @step("back", "back", n, callback)
    else
      @step("forward", "forward", n, callback)
       
  # mx_dir = "f" - forward, "r" - reverse, "n" - none
  step: (m0_dir, m1_dir, n, callback) =>
    @dsd.set_direction(m0_dir, m1_dir)
    @dsd.step_n(2, n, callback)
    
  delegate_methods: =>
    @stop = @dsd.stop
    @set_step_resolution = @dsd.set_step_resolution

# ========================
# = StepperDeviceOverlay =
# ========================    
class StepperDeviceOverlay
  @c_name = "StepperDeviceOverlay"
  @package_name = "ED-Stepper"
  @slots = "/sys/devices/bone_capemgr.9/slots"
  
  @uninstall: => 
    if @is_installed()
      slot_num = @get_slot_num()
      console.log "#{@c_name}.uninstall: uninstalling #{@package_name} from slot: #{slot_num}"
      sh.run "echo -#{slot_num} > #{@slots}"
    else
      console.log "#{@c_name}.uninstall: #{@package_name} not installed."
      
    throw "#{@c_name}.uninstall: Error #{@package_name} still installed" if @is_installed()
    
    
  @install: => 
    if @is_installed()
      console.log "#{@c_name}.install: already installed. Not installing again."
    else
      console.log "#{@c_name}.install: installing device overlay: #{@package_name}."
      sh.run "echo #{@package_name} > #{@slots}"
      
    console.log "#{@c_name}.install: #{@package_name} device overlay installed = #{@is_installed()}. Slot_num=#{@get_slot_num()}"
  
  @is_installed: => @get_slot() != ""
    
  @get_slot: => 
    result = sh.exec("cat #{@slots} | grep #{@package_name}")
    return result.stdout
  
  @get_slot_num: => parseInt @get_slot()
    
# ======================
# = Dual StepperDriver =
# ======================
# Using 2 easydriver stepper drive boards
class DualStepperDriver
  @c_name = "DualStepperDriver"
  @bb_pin = require("./bb_pin")    
     
  @pin_nums = [30,31,48,5,3, 60,50,51,4,2]
  
  @init: =>
    @init_pins()
  
  @init_pins: =>
    @pins = {}
    @pins[num] = @bb_pin.create("out", num) for num in @pin_nums
    @pinout = {
      0: {
        "ms1":       @pins[30]
        "ms2":       @pins[31]
        "sleep":     @pins[48]
        "direction": @pins[5]
        "step":      @pins[3]
      }
      1: {
        "ms1":       @pins[60]
        "ms2":       @pins[50]
        "sleep":     @pins[51]
        "direction": @pins[4]
        "step":      @pins[2]
      }
    }
      
  @pinout_for_motor: (n) => @pinout[n]
  
  @get_motors_from_m_n: (m_n) =>
    m_n = parseInt m_n
    switch m_n
      when 0 then [0]
      when 1 then [1]
      when 2, "both" then [0,1]
      else []
    
  @set_step_resolution: (m_n, res) => 
    res += ""
    res = res[0].toLowerCase()
    motors = @get_motors_from_m_n m_n
    console.log motors
    
    switch res
      when "full"[0], "1" 
        console.log "Setting step resolution to FULL m_n: #{m_n}" 
        for m_num in motors
          @set_pin(m_num, "ms1", 0)
          @set_pin(m_num, "ms2", 0)
    
      when "half"[0], "2"  
        console.log "Setting step resolution to HALF m_n: #{m_n}" 
        for m_num in motors
          @set_pin(m_num, "ms1", 0)
          @set_pin(m_num, "ms2", 1)
      
      when "quarter"[0], "4"  
        console.log "Setting step resolution to QUARTER m_n: #{m_n}" 
        for m_num in motors
          @set_pin(m_num, "ms1", 1)
          @set_pin(m_num, "ms2", 0)

      when "eigth"[0], "8"  
        console.log "Setting step resolution to EIGTH m_n: #{m_n}" 
        for m_num in motors
          @set_pin(m_num, "ms1", 1)
          @set_pin(m_num, "ms2", 1)
  
  @set_sleep: (m_n, val) => @set_pin(m_num, "sleep", val) for m_num in @get_motors_from_m_n m_n
  @sleep: (m_n) => @set_sleep(m_n, 1)
  @sleep: (m_n) => @set_sleep(m_n, 2)
  
  @set_direction: (m0_dir, m1_dir) => 
    console.log "Setting direction m0: #{m0_dir},  m1: #{m1_dir}"
    dirs = [m0_dir, m1_dir]
    for m_n in [0,1]
      dir = dirs[m_n]
      switch dir
        when 0, "b", "back" then @set_pin(m_n, "direction", 0)
        when 1, "f", "forward" then @set_pin(m_n, "direction", 1)
  
  @step_n: (m_n, num_steps, callback) =>
    @stopped = false
    @step_n_remaining = num_steps
    @step_n_num_steps_done = 0
    @step_n_callback = callback
    @step_n_m_n = m_n
    @step_timer = setInterval(@step_and_count, 10)
  
  @step_and_count: => 
    @step_and_count_done() if @stopped
    @step @step_n_m_n
    @step_n_remaining--
    @step_n_num_steps_done++
    @step_and_count_done() if @step_n_remaining is 0
  
  @step_and_count_done: () =>
    console.log "step_n done: #{@step_n_num_steps_done} steps"
    clearInterval @step_timer if @step_timer
    @stopped = false
    @step_n_callback() if @step_n_callback
    
  @step: (m_n) =>
    motors = @get_motors_from_m_n m_n
    console.log "steping m_n: #{m_n}"
    for m_num in motors
      @set_pin(m_num, "step", 0)
      @set_pin(m_num, "step", 1)
    
  @stop: => 
    console.log "Stop message sent"
    @stopped = true
    
  @set_pin: (m_num, pin_name, val) => @pinout[m_num][pin_name].set_val(val)
  
  
class Stepper
  # n: motor number (0,1)
  constructor: (n) -> 
    
create = () => new DualStepperController

module.exports = {
  create: create
}