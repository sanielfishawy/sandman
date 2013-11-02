# ===========
# = Vehicle =
# ===========
class window.Vehicle
  
  constructor: (params={}) ->
    params.diameter ||= 5
    @params = params
    @shape = new Kinetic.Group {x:0, y:0, rotationDeg: 0}
    
    @body = new VehicleBody @params
    @shape.add @body.shape
    
    
# =================
# = Vehicle Parts =
# =================
class window.VehicleBody
  
  constructor: (params={}) -> 
    @diameter = params.diameter
    @center = x:@diameter/2.0, y:@diameter/2.0
    @yaw = params.yaw || 0
    @shape = new Kinetic.Group {x:0, y:0, rotationDeg: 0}
    @add_circle()
    @add_square()
  
  add_circle: => 
    @radius = @diameter / 2.0
    @circle = new Kinetic.Circle {
      x: @radius.to_px(),
      y: @radius.to_px(),
      radius: @radius.to_px(),
      fillEnabled: false,
      stroke: 'black',
      strokeWidth: 1,
    }
    @shape.add @circle
  
  add_square: => 
    @square = CustomShapes.center_rect {
      center_x: @center.x.to_px(),
      center_y: @center.y.to_px(),
      width: @diameter.to_px(),
      height: @diameter.to_px(),
      fillEnabled: false,
      stroke: 'black',
      strokeWidth: 1,
    }
    @shape.add @square
      
class window.VehicleAxis
  
  constructor: (params={}) ->
    @diameter = params.diameter
    @center = params.center
    
    
class window.Wheel
  
  constructor: (option={}) ->
    @diameter = params.diameter || 3
    @center = params.center 
    @yaw = params.yaw || 0
    
    
class window.FrontIndicator
  
  constructor: (params={}) ->
    @length = params.length || 3
    @center = params.center
    @yaw = params.yaw || 0

    