# ===============
# = PointSensor =
# ===============
#   - A single point that can detect whether it is on or off of a surface.
#   - Sensor triggers an event on itself when it goes on or off.
#   - Sensor can be interrogated as to whether it is on or off the surface.
class window.PointSensor
  
  constructor: (params={}) -> 
    @id = params.id || "no_id"
    @x = normalize_to_num(params.x, 100)
    @y = normalize_to_num(params.y, 100)
    @state = null
    @define_shape()
    @add_event_handlers()
    @point_sensor_driver = new PointSensorDriver {sensor: @}
  
  define_shape: =>
    @shape ||= new Kinetic.Circle {
      x: @x
      y: @y
      radius: 0.25.to_px()
      stroke: "orange"
      strokeWidth: 1
      fillEnabled: false
    }
  
  add_event_handlers: => 
    @shape.on("move", @on_move)
  
  on_move: => 
    @state = @get_state()
    @set_indicator()
      
  get_state: => @point_sensor_driver.get_state()
  
  set_indicator: => 
    switch @state
      when "on"
        @shape.setFillEnabled true
        @shape.setStroke "green"
        @shape.setFill "green"
        @shape.set
      when "off"
        @shape.setFillEnabled true
        @shape.setStroke "red"
        @shape.setFill "red"
      else
        @shape.setFillEnabled false
        @shape.setStroke "orange"
    @shape.draw()
        
    
# =====================
# = PointSensorDriver =
# =====================
# Either emulated or real
#   - Emulated 
#     - Given the sensors position it determines the sensors state based on the emulated environment.
#   - Real
#     - Interrogates the hardware for the state of sensor.
# Polled for now Push in the future.
class window.PointSensorDriver
  
  constructor: (params={}) ->
    @sensor = params.sensor || raise "PointSensorDriver: You must specify a sensor"
    @k_sensor = normalize_to_kinetic @sensor
  
  get_state: => if @k_sensor.getAbsolutePosition().x > 150 or @k_sensor.getAbsolutePosition().y > 150 then "off" else "on"
  

# ==============
# = EdgeSensor =
# ==============
#  - Two point sensors separated by a distance 
#  - An edge is between them if one is on and the other is off
#  - Sensor triggers an event on itself when its state changes
#  - Geometry looks like this: inboard_sensor--d/2--centerx,y--d/2--outboard_sensor
class window.EdgeSensor
  
  constructor: (params={}) ->
    @id = params.id || "no_id"
    @d = params.d || 1
    @center_x = normalize_to_num(params.x, 0)
    @center_y = normalize_to_num(params.y, 0)
    @rotation = normalize_to_num(params.rotation, 0) # 0deg is along pos x axis
    @shape = new Kinetic.Group {x: @center_x.to_px(), y:@center_y.to_px(), rotationDeg:@rotation}
    @add_sensors()
    @add_line()
    # @add_center_mark()

  add_sensors: =>
    @inboard_sensor = new PointSensor {x: (-@d/2).to_px(), y:0}
    @outboard_sensor = new PointSensor {x: (@d/2).to_px(), y:0}
    @shape.add n_to_k s for s in [@inboard_sensor, @outboard_sensor]
  
  add_line: =>
    @line = new Kinetic.Line {
      points: [(-@d/2).to_px(), 0, (@d/2).to_px(), 0]
      stroke: "grey"
      stokeWidth:1
    }
    @shape.add @line
    
    
    
    
  