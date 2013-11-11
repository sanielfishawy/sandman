# ===============
# = PointSensor =
# ===============
#   - A single point that can detect whether it is on or off of a surface.
#   - Sensor triggers an event on itself when it goes on or off.
#   - Sensor can be interrogated as to whether it is on or off the surface.
class window.PointSensor
  
  constructor: (params={}) -> 
    @sequencer = params.sequencer
    @id = params.id || "no_id"
    @x = normalize_to_num(params.x, 100)
    @y = normalize_to_num(params.y, 100)
    @shape = new Kinetic.Group {x: @x.to_px(), y:@y.to_px(), rotationDeg:0}
    @add_circle()
    @state = null
    @add_event_handlers()
    @point_sensor_driver = new PointSensorDriver {sensor: @}
  
  add_circle: =>
    @circle = new Kinetic.Circle {
      x: 0
      y: 0
      radius: 0.25.to_px()
      stroke: "orange"
      strokeWidth: 1
      fillEnabled: false
    }
    @shape.add @circle
  
  add_event_handlers: => $(@sequencer).on("sense", @sense)
  
  sense: => @get_state()
      
  get_state: => 
    new_state = @point_sensor_driver.get_state()
    @set_indicator new_state 
    $(document).trigger "sensor_change" if new_state isnt @state 
    @state = new_state
    return @state
  
  set_indicator: (state) => 
    switch state
      when "on"
        @circle.setFillEnabled true
        @circle.setStroke "green"
        @circle.setFill "green"
      when "off"
        @circle.setFillEnabled true
        @circle.setStroke "red"
        @circle.setFill "red"
      else
        @circle.setFillEnabled false
        @circle.setStroke "orange"
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
  
  @over_ride: null
  
  constructor: (params={}) ->
    @sensor = params.sensor || raise "PointSensorDriver: You must specify a sensor"
    @k_sensor = normalize_to_kinetic @sensor
      
  get_state: => 
    # Note I believe this relies on the surface layer being the first layer checked by getIntersection because it is intatiated first in Stage.js.
    s = @k_sensor.getStage().getIntersection @k_sensor.getAbsolutePosition()
    if s and s.shape and s.shape.getName() is "surface" then "on" else "off"    
  

# ==============
# = EdgeSensor =
# ==============
#  - Two point sensors separated by a distance 
#  - An edge is between them if one is on and the other is off
#  - Sensor triggers an event on itself when its state changes
#  - Geometry looks like this: inboard_sensor--d/2--centerx,y--d/2--outboard_sensor
class window.EdgeSensor
  
  constructor: (params={}) ->
    @sequencer = params.sequencer
    @id = params.id || "no_id"
    @d = params.d || 1.5
    @center_x = normalize_to_num(params.x, 0)
    @center_y = normalize_to_num(params.y, 0)
    @rotation = normalize_to_num(params.rotation, 0) # 0deg is along pos x axis
    @shape = new Kinetic.Group {x: @center_x.to_px(), y:@center_y.to_px(), rotationDeg:@rotation}
    @add_sensors()
    @add_line()
    @add_orientation_tic()
    @add_event_handlers()
    @state = null
  
  add_orientation_tic: =>
    @orientation_tic = OrientationTic.shape((@d/2)+0.7, 0)
    @shape.add @orientation_tic
     
  add_sensors: =>
    @inboard_sensor = new PointSensor {sequencer: @sequencer, id:"#{@id}_inboard", x: (-@d/2), y:0}
    @outboard_sensor = new PointSensor {sequencer: @sequencer, id:"#{@id}_outboard", x: (@d/2), y:0}
    @shape.add n_to_k s for s in [@inboard_sensor, @outboard_sensor]
  
  add_line: =>
    @line = new Kinetic.Line {
      points: [(-@d/2).to_px(), 0, (@d/2).to_px(), 0]
      stroke: "grey"
      strokeWidth:1
    }
    @shape.add @line
  
  rotate: (deg) => @shape.rotateDeg deg
  
  add_event_handlers: => $(@sequencer).on("sense", @sense)

  sense: => @get_state()

  get_state: => 
    @sensor_state = inboard: @inboard_sensor.get_state(), outboard: @outboard_sensor.get_state()
    if @sensor_state.inboard is "on" and @sensor_state.outboard is "on"
      @state = "in" 
    else if @sensor_state.inboard is "off" and @sensor_state.outboard is "off"
      @state = "out" 
    else if @sensor_state.inboard is "on" and @sensor_state.outboard is "off"
      @state = "on" 
    else if @sensor_state.inboard is "off" and @sensor_state.outboard is "on" 
      @state = "error" 
      console.log "EdgeSensor[#{@id}] - my out board sensor is on and inboard sensor is off. Does not compute:(" 
    else 
      @state = null
    @set_indicator()
    @state

  set_indicator: => 
    switch @state
      when "in"
        for shape in [@line, @orientation_tic]
          shape.setStroke "blue" 
          shape.setFill "blue"
      when "on"
       for shape in [@line, @orientation_tic]
         shape.setStroke "green" 
         shape.setFill "green"
      when "out"
        for shape in [@line, @orientation_tic]
          shape.setStroke "red" 
          shape.setFill "red"
      when "error"
        for shape in [@line, @orientation_tic]
          shape.setStroke "yellow" 
          shape.setFill "yellow"
        
    @line.draw()


# ==================
# = Tangent Sensor =
# ==================      
# Two edge sensors separated by a distance d
# One sensor is leading the other is trailing
# These can tell if the vehilce is acute or obtuse of the tangent and whether it is on the tangent completly in or completely out.
class window.TangentSensor
  constructor: (params={}) ->
    @sequencer = params.sequencer
    @id = params.id
    @d = params.d || 2.0
    @center_x = normalize_to_num(params.x, 0)
    @center_y = normalize_to_num(params.y, 0)
    @rotation = normalize_to_num(params.rotation, 0) # 0deg is with tangent along y axis
    @shape = new Kinetic.Group {x: @center_x.to_px(), y:@center_y.to_px(), rotationDeg:@rotation}
    @add_sensors()
    @add_line()
    @add_orientation_tic()
    @add_event_handlers()
    @state = null
  
  add_orientation_tic: =>
    @orientation_tic = OrientationTic.shape(0, (-@d/2)-0.7)
    @shape.add @orientation_tic
  
  add_sensors: =>
    @trailing_sensor = new EdgeSensor {sequencer: @sequencer, id:"#{@id}_leading", y: (-@d/2), x:0}
    @leading_sensor = new EdgeSensor {sequencer: @sequencer, id:"#{@id}_trailing", y: (@d/2), x:0}
    @shape.add n_to_k s for s in [@leading_sensor, @trailing_sensor]
  
  add_line: =>
    @line = new Kinetic.Line {
      points: [0, (-@d/2).to_px(), 0, (@d/2).to_px()]
      stroke: "grey"
      strokeWidth:1
    }
    @shape.add @line

  rotate: (deg) => @shape.rotateDeg deg
  
  add_event_handlers: => 
    $(@sequencer).on("sense", @sense)

  sense: => @get_state()

  get_state: => 
    @sensor_state = leading: @leading_sensor.get_state(), trailing: @trailing_sensor.get_state()
    
    unless @sensor_state.leading and @sensor_state.trailing
      @state = null
      return @set_indicator()
      
    switch @sensor_state.leading
      when "in"
        switch @sensor_state.trailing
          when "in"
            @state = "in"
          when "on"
            @state = "front_turn_out_p_t"
          when "out"
            @state = "front_turn_out_p_c"
      when "on"
        switch @sensor_state.trailing
          when "in"
            @state = "back_turn_out_p_l"
          when "on"
            @state = "tangent"
          when "out"
            @state = "back_turn_in_p_l"
      when "out"
        switch @sensor_state.trailing
          when "in"
            @state = "front_turn_in_p_c"
          when "on"
            @state = "front_turn_in_p_t"
          when "out"
            @state = "out"
    @set_indicator()
    @state
                
  set_indicator: => 
    switch @state
      when "in"
        for shape in [@line, @orientation_tic]
          shape.setStroke "blue" 
      when "on"
        shape.setStroke "green" for shape in [@line, @orientation_tic]
      when "out"
        for shape in [@line, @orientation_tic]
          shape.setStroke "red"
          shape.setFill "red"
      when null
        shape.setStroke "yellow" for shape in [@line, @orientation_tic]
    @line.draw()
  

# ==================
# = OrientationTic =
# ==================
class window.OrientationTic
  
  @shape: (x,y) =>
    new Kinetic.Circle {
      x: x.to_px()
      y: y.to_px()
      radius: 0.1.to_px()
      stroke:"grey"
      strokeWidth:1
      fillEnabled: true
      fill: "grey"
    }
    
    
    
    
  