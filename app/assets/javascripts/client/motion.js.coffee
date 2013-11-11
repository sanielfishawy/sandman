class window.VehicleMotionHandler
  
  constructor: (params) ->
    @sequencer = params.sequencer || raise "VehicleMotionHandler: I need a sequencer."
    @vehicle = params.vehicle || raise "VehicleMotionHandler: I need a vehicle."
    @k_vehicle = n_to_k @vehicle 
    @motion_queue = []
    @motion_history = []
    @set_event_handlers()
    
    @motion_unit_px = 1 #px
    @motion_unit_in = @motion_unit_px / Conversion.px_per_inch #inch
    @rotation_unit = 2 #degree
    
    @stop_on_sensor_change = false
  
  set_event_handlers: => 
    $(@sequencer).on("move", @handle_motion)
    $(document).on("sensor_change", @handle_sensor_change)
    
  handle_sensor_change: => @motion_queue.shift() if @current_move() and @current_move().stop_on_sensor_change
  
  current_move: => @motion_queue[0]
  
  handle_motion: => 
    if @current_move()
      switch @current_move().motion
        when "move"
          @handle_move()
        when "rot"
          @handle_rotate()
  
  handle_move: => 
    rotation = @k_vehicle.getRotation()
    delta_x = @current_move().dir * @motion_unit_px * Math.cos(rotation)
    delta_y = @current_move().dir * @motion_unit_px * Math.sin(rotation)
    @k_vehicle.move x:delta_x, y:delta_y
    @after_motion()
 
  handle_rotate: => 
    @k_vehicle.rotateDeg @current_move().dir * @rotation_unit
    @after_motion()
  
  after_motion: => 
    @current_move().num_motion_units-- if typeof @current_move().num_motion_units is "number"
    @current_move().num_done++
    @kill_current_move() if @current_move().num_motion_units <= 0 
    $(document).trigger "after_move"
  
  kill_current_move: =>   
    @motion_history.push @current_move()
    @motion_queue.shift() 
  
  kill_all_moves: => @motion_queue = []
  
  # Move d inches in direction we are pointing. d can be neg to go backwards. "+"/"-" means keep going till sensor change
  move: (d, stop_on_sensor_change=true) => @add_motion("move", d, stop_on_sensor_change)  
     
  rotate: (deg, stop_on_sensor_change=true) => @add_motion("rot", deg, stop_on_sensor_change)  
  
  rotate_to: (angle, stop_on_sensor_change=true) => 
    delta_deg = angle - @current_rotation()
    delta_deg = if delta_deg > 180 then delta_deg - 360 else delta_deg
    @rotate(delta_deg, stop_on_sensor_change)
  
  add_motion: (type, d, stop_on_sensor_change) => 
    @motion_queue.push {
      motion: type
      num_motion_units: @get_num_motion_units(type, d)
      num_done:0
      dir: @get_dir_from_motion d
      stop_on_sensor_change: stop_on_sensor_change
    }
  
  get_num_motion_units: (type, d) =>
    return d unless typeof d is "number"
    if type is "rot" or type is "rev"
      Math.round( Math.abs(1.0*d / @rotation_unit) )
    else
      Math.round( Math.abs(1.0*d / @motion_unit_in) )
      
  get_dir_from_motion: (m) => 
    if typeof m is "number"
      if m >= 0 then 1 else -1
    else
      if m.match /-/ then -1 else 1
  
  # Revolve the robot around a point x,y
  revolve: (point, deg=360, stop_on_sensor_change=true) => 
    dir = @get_dir_from_motion(deg)
    delta_x = point.x - @current_position().x
    delta_y = point.y - @current_position().y
    angle = 180 + Math.atan(delta_y/delta_x).to_deg()
    radius = Math.pow(Math.pow(delta_x, 2) + Math.pow(delta_y, 2), 1/2).to_inch()
    d = radius * Math.sin(@rotation_unit.to_rad())
    throw "VMH.revolve: radius is too tight" if d < 2*@motion_unit_in
    tangent = angle + 90
    @rotate_to(tangent)
    @move(d/2, false)
    num_rotation_units = @get_num_motion_units("rev", deg)
    for step in [1..num_rotation_units]
      @rotate(-dir*@rotation_unit, stop_on_sensor_change)
      @move(dir*d, stop_on_sensor_change)
    return deg
        
  current_position: => @k_vehicle.getAbsolutePosition()
  current_rotation: => @k_vehicle.getRotationDeg()
    
  go_to_point: (x,y) =>
    
    
    
    
  