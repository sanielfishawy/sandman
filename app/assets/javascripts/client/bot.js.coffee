class window.Algorithm
  
  constructor: (vehicle)  -> 
    @sand = vehicle
    @mh = @sand.vehicle_motion_handler
        
  move_back: => 
    params = type: "move", d: -3, speed: "fast", stop_on_sensor_change: false, on_motion_complete: @done_move_back
    @mh.add_motion params
  
  done_move_back: => @rotate_random()
  
  rotate_random: => 
    deg = (180 - 5) + 10*Math.random()
    params = type: "rot", d: deg, speed: "fast", stop_on_sensor_change: true, on_motion_complete: @done_rotate
    @mh.add_motion params
  
  done_rotate: => @move_forward()
  
  move_forward: =>
    params = type: "move", d: "+", speed: "fast", stop_on_sensor_change: true, on_motion_complete: @done_move_forward
    @mh.add_motion params
  
  done_move_forward: => @move_back()
    
  


class window.SimpleMotionHandler
  
  constructor: ->
    
  rotate: (deg) -> 
    console.log "Rotated #{deg} degrees."
  
  move: (inches) -> 
    console.log "Move #{inches} inches."


class window.SimpleSensor
  
  constructor: -> 

  is_off: -> 
    state = if Math.random() < .2 then "on" else "off"
    console.log state
    return state





window.sense_many = (num, sense) ->  
  for s in [0..num]
    sense()

window.step = ->
  # send_step_to_beagle_stepper_driver()
  console.log "I pulsed the stepper."
  
window.turn_to = (dir) => 
  # send_step_to_beagle_stepper_driver_for_turn() 
  console.log "I turned to #{dir}"
  
  
