# ===========
# = Vehicle =
# ===========
class window.Vehicle
  
  constructor: (params={}) ->
    params.diameter ||= 10.0
    @diameter = params.diameter
    @radius = @diameter / 2.0
    @x = params.x || 0
    @y = params.y || 0
    @rotation = params.rotation || 0
    @params = params
    
    @sequencer = new Sequencer
    @add_shape()
    @add_sensors()
    @vehicle_motion_handler = new VehicleMotionHandler sequencer: @sequencer, vehicle: @
    @delegate_methods()
    @s_start()
      
  add_shape: =>
    @shape = new Kinetic.Group {x:@x.to_px(), y:@y.to_px(), rotationDeg: @rotation}
    
    @body = new VehicleBody @params
    @shape.add @body.shape
  
  add_sensors: =>
    @front_sensor = new PointSensor id: "front_sensor", sequencer: @sequencer, x:@radius, y:0
    @shape.add @front_sensor.shape
    
    @right_sensor = new TangentSensor id: "right_sensor", sequencer: @sequencer, x:0, y:@radius, rotation: 90
    @shape.add @right_sensor.shape
    
    @left_sensor = new PointSensor id: "left_sensor", sequencer: @sequencer, x:0, y:-@radius
    @shape.add @left_sensor.shape
  
  left_sensor_position: => 
    @left_sensor.shape.getAbsolutePosition()
  
  delegate_methods: =>
    @s_start = @sequencer.start
    @s_stop = @sequencer.stop
    
    @move = @vehicle_motion_handler.move
    @rotate = @vehicle_motion_handler.rotate
    @rotate_to = @vehicle_motion_handler.rotate_to
    @revolve = @vehicle_motion_handler.revolve
    @rot = @vehicle_motion_handler.rotate
    @kill_move = @vehicle_motion_handler.kill_current_move
    @kill_all_moves = @vehicle_motion_handler.kill_all_moves
    @current_position = @vehicle_motion_handler.current_position
    @current_rotation = @vehicle_motion_handler.current_rotation
      
    
# =================
# = Vehicle Parts =
# =================
class window.VehicleBody
  
  constructor: (params={}) -> 
    @diameter = params.diameter
    @radius = @diameter / 2.0
    @rotation = params.rotation || 0
    @shape = new Kinetic.Group {x:0, y:0, rotationDeg: @rotation}
    @add_circle()
    @add_arrow()
  
  add_circle: => 
    @circle = new Kinetic.Circle {
      x:0
      y:0
      radius: @radius.to_px()
      fillEnabled: false
      stroke: '#999'
      strokeWidth: 1
    }
    @shape.add @circle
      
  add_arrow: =>
    @arrow = new CustomShapes::Arrow {
      head_x: @radius + 1.25
      head_y: 0
      stroke: "blue"
    }
    @shape.add @arrow.shape

    