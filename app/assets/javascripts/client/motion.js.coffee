class window.VehicleMotionHandler
  
  constructor: (params) ->
    @sequencer = params.sequencer || raise "VehicleMotionHandler: I need a sequencer."
    @vehicle = params.vehicle || raise "VehicleMotionHandler: I need a vehicle."
    @k_vehicle = n_to_k @vehicle 
    @motion_queue = []
    @motion_history = []
    @set_event_handlers()
    
    @motion_unit_px = .25 #px
    @motion_unit_in = @motion_unit_px / Conversion.px_per_inch #inch
    @rotation_unit = 3 #degree
    
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
    delta_deg = (angle.pos_deg() - @current_rotation()).pos_deg()
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
  revolve: (params={}) => 
    point = params.point || throw "revolve: 'point' required. I need a point to revolve around."
    deg = params.deg || throw "revolve: 'deg' required. I need to know how many degrees you want me to go around the point."
    hand = params.hand || throw "revolve: 'hand' required. I need to know whether you want me to take the point on my 'left' or 'right' hand side."
    stop_on_sensor_change = params.stop_on_sensor_change || true
    
    rotation_dir = @get_dir_from_motion(deg)
    
    @rc = new RevolveCalculator {
      vehicle: @vehicle
      point: point
      hand: hand
      rotation_dir: rotation_dir
    }
    
    d = @rc.radius * Math.sin(@rotation_unit.to_rad())
    throw "VMH.revolve: radius is too tight" if d < 2*@motion_unit_in
    
    @rotate_to @rc.tangent(hand)
    @move(d/2, false)
    num_rotation_units = @get_num_motion_units("rev", deg)
    for step in [1..num_rotation_units]
      @rotate(rotation_dir*@rotation_unit, stop_on_sensor_change)
      @move(@rc.move_dir*d, stop_on_sensor_change)
    return deg
        
  current_position: => @k_vehicle.getAbsolutePosition()
  current_rotation: => @k_vehicle.getRotationDeg().pos_deg()
    
  go_to_point: (x,y) =>
    
    
class window.RevolveCalculator
  
  constructor: (params={}) -> 
    @vehicle = params.vehicle || throw "RevolveCalculator: I need a 'vehicle'"
    @point = params.point || throw "RevolveCalculator: I need a 'point'"
    @hand = params.hand || throw "RevolveCalculator: I need a 'hand' to know which side the vehicle you want the point pass on 'left', 'right' or 'nearest'-given current rotation"     
    @rotation_dir = params.rotation_dir || throw "RevolveCalculator: I need a 'rotation_dir'. 1 for clockwise. -1 for counter clockwise."
    
    @delta_x = @vehicle.current_position().x - @point.x
    @delta_y = @vehicle.current_position().y - @point.y
    @angle_point_to_vehicle = Math.atan2(@delta_y, @delta_x).to_deg().pos_deg()
    @radius = Math.pow(Math.pow(@delta_x, 2) + Math.pow(@delta_y, 2), 1/2).to_inch()
    
    @tangent_rh = (@angle_point_to_vehicle + 90).pos_deg()
    @tangent_lh = (@angle_point_to_vehicle + 270).pos_deg()
    
    @move_dir = @get_move_dir()   
    
    offset_x = main_stage.test_layer.getOffset().x
    offset_y = main_stage.test_layer.getOffset().y
    line = new Kinetic.Line {
      points: [@point.x + offset_x, @point.y + offset_y, @vehicle.current_position().x + offset_x, @vehicle.current_position().y + offset_y]
      stroke: "red"
      strokeWidth: 1
    } 
    main_stage.test_add  line
          
  get_move_dir: => 
    return 1 if @hand is "right" and @rotation_dir is 1
    return -1  if @hand is "right" and @rotation_dir is -1
    return 1 if @hand is "left" and @rotation_dir is -1
    return -1  if @hand is "left" and @rotation_dir is 1
  
  tangent: (hand) => 
    throw "RevolveCalculator.tangent: I need a 'left' or 'right' hand." unless hand
    if hand is "right" then @tangent_rh else @tangent_lh
    
  
  
    
  