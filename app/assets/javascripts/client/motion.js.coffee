# ======================
# = VehicleMotionQueue =
# ======================
class window.VehicleMotionQueue
  
  constructor: () ->
    @motion_queue = []
    @motion_history = []
    
  current_move: => @motion_queue[0]
  last_move: => @motion_history.last()
  
  complete_current_move: (status) =>
    @current_move().status = status
    @motion_history.push @current_move()
    @current_move().on_motion_complete(@current_move()) if @current_move().on_motion_complete
    @motion_queue.shift() 
    
  kill_current_move: => @complete_current_move "fail" 
  
  kill_all_moves: => @motion_queue = []
  
  # Move d inches in direction we are pointing. d can be neg to go backwards. "+"/"-" means keep going till sensor change
  move: (d, speed="fast", stop_on_sensor_change=true) => @add_motion type:"move", d:d, speed:speed, stop_on_sensor_change: stop_on_sensor_change 
     
  rotate: (deg, speed="fast", stop_on_sensor_change=true) => @add_motion type:"rot", d:deg, speed:speed, stop_on_sensor_change:stop_on_sensor_change
  
  add_motion: (params={}) => 
    type = params.type || throw "add_motion: I need a type."
    d = params.d || throw "add_motion: I need a d."
    speed = params.speed || throw "add_motion: I need a speed."
    stop_on_sensor_change = params.stop_on_sensor_change  
    throw "add_motion: I need a stop_on_sensor_change." if stop_on_sensor_change is undefined
    on_motion_complete = params.on_motion_complete
    
    @motion_queue.push {
      motion: type
      type: type
      speed: speed
      d: d
      stop_on_sensor_change: stop_on_sensor_change
      on_motion_complete: on_motion_complete
    }
    $(document).trigger "motion_added"
     
    
# =========================
# = RVehicleMotionHandler =
# =========================
# MotionHandler for the real vehicle
# Pulls a motion off the queue. Dispatches it to the remote vehicle over socketio
class window.RVehicleMotionHandler
  
  constructor: (params) ->
    @vmq = params.vmq || raise "VehicleMotionHandler: I need a vehicle_motion_queue as vmq"
    @current_move =  @vmq.current_move
    @remote_vehicle_command = SocketIO.call_api
    @rvc = @remote_vehicle_command
    @set_event_handlers()
    @wake()
    @set_step_resolution("full")
    
  set_event_handlers: =>
    $(document).on("motion_added", @handle_move)
  
  get_dir: (m) => 
    if typeof m is "number"
      if m >= 0 then 1 else -1
    else
      if m.match /-/ then -1 else 1
  
  get_num_steps: (m) => 
    if typeof m is "number"
      return Math.round(Math.abs m)
    else
      return -1
      
  handle_move: => 
    if @current_move()
      @init_current_move_if_necessary()
      @send_current_move()
  
  send_current_move: => 
    @rvc("Dsc", @current_move().type, [@current_move().dir, @current_move().num_steps], @move_done)
  
  wake: (callback=@rvc_done) => @rvc("Dsc", "wake", [2], callback)
  
  stop: (callback=@rvc_done) => @rvc("Dsc", "stop", [], callback)
  
  set_rpm: (rpm, callback=@rvc_done) => @rvc("Dsc", "set_rpm", [rpm], callback)
  
  rvc_done: (response) => console.log response.msg
  
  set_step_resolution: (res, callback=@rvc_done) => @rvc("Dsc", "set_step_resolution", [2, res], callback)
    
  move_done: (response) =>
    console.log "RVehicleMotionHandler.move_done: #{@current_move().motion}: #{response.msg}"
    @vmq.complete_current_move("pass")
    @handle_move()

  init_current_move_if_necessary: =>
    if @current_move() and @current_move().num_steps is undefined
      @current_move().dir =  @get_dir @current_move().d
      @current_move().num_steps = @get_num_steps @current_move().d
  
# =========================
# = KVehicleMotionHandler =
# =========================
# MotionHandler for the kinetic vehicle
class window.KVehicleMotionHandler
  
  constructor: (params) ->
    @sequencer = params.sequencer || raise "VehicleMotionHandler: I need a sequencer."
    @vehicle = params.vehicle || raise "VehicleMotionHandler: I need a vehicle."
    @vmq = params.vmq || raise "VehicleMotionHandler: I need a vehicle_motion_queue as vmq"
    @complete_current_move = @vmq.complete_current_move
    @current_move =  @vmq.current_move
    @k_vehicle = n_to_k @vehicle 
    @set_event_handlers()
    
    @motion_unit_px = fast:5, slow:.5 #px
    @motion_unit_in = fast: @motion_unit_px.fast/Conversion.px_per_inch, slow: @motion_unit_px.slow/Conversion.px_per_inch #inch
    @rotation_unit = fast:3, slow:1 #degree

  get_num_motion_units: (type, d, speed) =>
    throw "get_num_motion_units(): I need a speed" unless speed
    return d unless typeof d is "number"
    if type is "rot" or type is "rev"
      Math.round( Math.abs(1.0*d / @rotation_unit[speed]) )
    else
      Math.round( Math.abs(1.0*d / @motion_unit_in[speed]) )
    
  get_dir_from_motion: (m) => 
    if typeof m is "number"
      if m >= 0 then 1 else -1
    else
      if m.match /-/ then -1 else 1
      
  set_event_handlers: => 
    $(@sequencer).on("move", @handle_motion)
    $(document).on("sensor_change", @handle_sensor_change)
    
  handle_sensor_change: => @complete_current_move("pass") if @current_move() and @current_move().stop_on_sensor_change
    
  handle_motion: => 
    if @current_move()
      @init_current_move_if_necessary()
      switch @current_move().motion
        when "move"
          @handle_move()
        when "rot"
          @handle_rotate()
  
  init_current_move_if_necessary: =>
    if @current_move() and @current_move().num_motion_units is undefined
      @current_move().num_motion_units = @get_num_motion_units(@current_move().type, @current_move().d, @current_move().speed)
      @current_move().num_done = 0
      @current_move().dir =  @get_dir_from_motion @current_move().d
    
    
  handle_move: => 
    rotation = @k_vehicle.getRotation()
    delta_x = @current_move().dir * @motion_unit_px[@current_move().speed] * Math.cos(rotation)
    delta_y = @current_move().dir * @motion_unit_px[@current_move().speed] * Math.sin(rotation)
    @k_vehicle.move x:delta_x, y:delta_y
    @after_motion()
 
  handle_rotate: => 
    @k_vehicle.rotateDeg @current_move().dir * @rotation_unit[@current_move().speed]
    @after_motion()
  
  after_motion: => 
    @current_move().num_motion_units-- if typeof @current_move().num_motion_units is "number"
    @current_move().num_done++
    @complete_current_move("pass") if @current_move().num_motion_units <= 0 
    $(document).trigger "after_move"
    
  rotate_to: (angle, stop_on_sensor_change=true) => 
    delta_deg = (angle.pos_deg() - @current_rotation()).pos_deg()
    delta_deg = if delta_deg > 180 then delta_deg - 360 else delta_deg
    fast_delta_deg = @rotation_unit.fast * Math.floor(delta_deg/@rotation_unit.fast)
    slow_delta_deg = Math.round(delta_deg % @rotation_unit.fast)
    @vmq.rotate(fast_delta_deg, "fast", stop_on_sensor_change) if fast_delta_deg
    @vmq.rotate(slow_delta_deg, "slow", stop_on_sensor_change) if slow_delta_deg
  
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
    
    d = @rc.radius * Math.sin(@rotation_unit.fast.to_rad())
    throw "VMH.revolve: radius is too tight" if d < 2*@motion_unit_in.slow
    
    @rotate_to @rc.tangent(hand)
    @vmq.move(d/2, "slow", false)
    num_rotation_units = @get_num_motion_units("rev", deg, "fast")
    for step in [1..num_rotation_units]
      @vmq.rotate(rotation_dir*@rotation_unit.fast, "fast", stop_on_sensor_change)
      @vmq.move(@rc.move_dir*d,"slow", stop_on_sensor_change)
    # Construction.clear()
    return deg
        
  current_position: => @k_vehicle.getAbsolutePosition()
  current_rotation: => @k_vehicle.getRotationDeg().pos_deg()
    
  go_to_point: (x,y) =>
    
# =====================
# = RevolveCalculator =
# =====================
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
    
    Construction.add_line(@point, @vehicle.current_position())
          
  get_move_dir: => 
    return 1 if @hand is "right" and @rotation_dir is 1
    return -1  if @hand is "right" and @rotation_dir is -1
    return 1 if @hand is "left" and @rotation_dir is -1
    return -1  if @hand is "left" and @rotation_dir is 1
  
  tangent: (hand) => 
    throw "RevolveCalculator.tangent: I need a 'left' or 'right' hand." unless hand
    if hand is "right" then @tangent_rh else @tangent_lh

# ======================
# = SmartMoveSequencer =
# ======================
class window.SmartMoveSequencer
  
  constructor: (params={}) ->
    @vehicle = params.vehicle || throw "SmartMoveSequencer: I need a vehicle"
    @vmq = params.vmq || throw "SmartMoveSequencer: I need a vehicle_motion_queue as params.vmq."
    @sequencer = params.sequencer || raise "SmartMoveSequencer: I need a sequencer."
    @smart_move_queue = []
    @smart_move_history = []
    @add_event_handlers()
    
  add_event_handlers: =>
    $(@sequencer).on("move", @handle_smart_move)
  
  handle_smart_move: => 
    return unless @current_smart_move()
    switch @current_smart_move().status
      when "init"
        console.log "Starting smart_move: #{@current_smart_move().type}"
        @current_smart_move().status = "started"
        @current_smart_move().next()
      when "pass", "fail"
        @complete_current_smart_move()
  
  unshift_smart_move: (class_name) => 
    sm = @create_smart_move class_name
    @smart_move_queue.unshift sm
    
  add_smart_move: (class_name) => 
    sm = @create_smart_move class_name
    @smart_move_queue.push sm
  
  create_smart_move: (class_name) =>
    new window[class_name]({
      id: (new Date).getTime()
      vehicle: @vehicle
      vmq: @vmq
      sms: @
    })
         
  complete_current_smart_move: => 
    @smart_move_history.push @current_smart_move()
    @smart_move_queue.shift()
        
  current_smart_move: => @smart_move_queue.first()
  last_smart_move: => @smart_move_history.last()

    
        
# =============
# = SmartMove =
# =============
class window.SmartMove
  
  constructor: (params={}) -> 
    @id = params.id
    @vehicle = params.vehicle || throw "SmartMove: I need a vehicle."
    @vmq = params.vmq || throw "SmartMove: I need a vehicle_motion_queue as params.vmq."
    @sms = params.sms
    @status = "init"
    @init()
  
  init: =>
  
  next: => 

  exec_current_motion: => @vmq.add_motion @current_motion if @current_motion


# =============
# = Goto Edge =
# =============
class window.GoToEdge extends SmartMove
    
  init: =>
    @type = "GoToEdge"
    @step = -1
    @motion_sequence = [
      {type: "move", d: "+", speed: "fast", stop_on_sensor_change: true, on_motion_complete: @next}
      {type: "move", d: "-", speed: "slow", stop_on_sensor_change: true, on_motion_complete: @next}
      {type: "move", d: .5, speed: "slow", stop_on_sensor_change: false, on_motion_complete: @next}
    ]
  
  next: => 
    @status = "running"
    if @step is -1 and @vehicle.a_sensor_out()
      @status = "fail"
    else if @step is @motion_sequence.length - 1
      @status = "pass"
    else
      @step++ 
      @status = "running"
      @current_motion = @motion_sequence[@step]
      @exec_current_motion()

# =====================
# = PutRightSensorOut =
# =====================
class window.PutRightSensorOut extends SmartMove
  
  init: =>
    @type = "PutRightSensorOut"
    @found = false
    
  next: => 
    return @go_to_edge_first() if @status is "started" and @vehicle.all_sensors_in()
      
    @status = "running"
    if @vehicle.right_sensor.get_state() isnt "in"
      if not @found
        @found = true
        @current_motion = type:"rot", d:-3, speed: "slow", stop_on_sensor_change:false, on_motion_complete: @next
        @exec_current_motion() 
      else
        @status = "pass"
    else
      @current_motion = type:"rot", d:-360, speed: "fast", stop_on_sensor_change:true, on_motion_complete: @next
      @exec_current_motion() 

  go_to_edge_first: => 
    @sms.unshift_smart_move "GoToEdge"
    @status = "init"


# ================
# = GoToParallel =
# ================
class window.GoToParallel extends SmartMove
  
  init: => 
    @type = "GoToParallel"
    
  next: => 
    return @put_right_sensor_out() if @status is "started" and @vehicle.right_sensor.get_state() is "in"
  
  put_right_sensor_out: => 
    @sms.unshift_smart_move "PutRightSensorOut"
    @status = "init"
