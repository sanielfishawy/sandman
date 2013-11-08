class window.VehicleMotionHandler
  
  constructor: (params) ->
    @sequencer = params.sequencer || raise "VehicleMotionHandler: I need a sequencer."
    @vehicle = params.vehicle || raise "VehicleMotionHandler: I need a vehicle."
    @k_vehicle = n_to_k @vehicle 
    @motion_queue = []
    @set_event_handlers()
    
    @motion_unit_px = 10.0 #px
    @motion_unit_in = @motion_unit_px / Conversion.px_per_inch #inch
    @rotation_unit = 2 #degree
    
    @stop_on_sensor_change = false
  
  set_event_handlers: => $(@sequencer).on("move", @handle_motion)
  
  handle_motion: => 
    @current_move = @motion_queue[0]
    if @current_move
      switch @current_move.motion
        when "move"
          @handle_move()
        when "rot"
          @handle_rotate()
  
  handle_move: => 
    rotation = @k_vehicle.getRotation()
    delta_x = @current_move.dir * @motion_unit_px * Math.cos(rotation)
    delta_y = @current_move.dir * @motion_unit_px * Math.sin(rotation)
    @k_vehicle.move x:delta_x, y:delta_y
    @current_move.num_motion_units--
    @motion_queue.shift() if @current_move.num_motion_units <= 0
 
  handle_rotate: => 
    @k_vehicle.rotateDeg @current_move.dir * @rotation_unit
    @current_move.num_rotation_units-- 
    @motion_queue.shift() if @current_move.num_rotation_units <= 0 
    
  # Move d inches in direction we are pointing. d can be neg to go backwards.
  move: (d) =>
    @motion_queue.push {
      motion: "move"
      num_motion_units: Math.round( Math.abs(1.0*d / @motion_unit_in) )
      dir: if d >= 0 then 1 else -1
    }
     
  rotate: (deg) =>
    @motion_queue.push {
      motion: "rot"
      num_rotation_units: Math.round( Math.abs(1.0*deg / @rotation_unit) )
      dir: if deg >= 0 then 1 else -1
    }
    
    
  revolve: (deg, x, y) => 
  go_to_point: (x,y) =>
    
    
    
    
  