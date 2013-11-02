$(document).ready -> 
  window.rect = new Kinetic.Rect {
    x: 50,
    y: 50,
    width: 100,
    height: 50,
    fillEnabled: false,
    stroke: 'red',
    strokeWidth: 1,
  }

  window.rect2 = new Kinetic.Rect {
    x: 0,
    y: 0,
    width: 100,
    height: 100,
    stroke: 'red',
    strokeWidth: 1,
    fillEnabled: false,
  }
  
  window.circle_pos = new Kinetic.Circle {
    x:10,
    y:0,
    radius:5,
    stroke: "green",
    strokeWidth: 1,
    fillEnabled: false,
  }
  
  window.circle_neg = new Kinetic.Circle {
    x:-10,
    y:0,
    radius:5,
    stroke: "red",
    strokeWidth: 1,
    fillEnabled: false,
  }
  
  window.cir_group = new Kinetic.Group {x:200, y:200}
  cir_group.add circle_neg
  cir_group.add circle_pos
  
  window.main_stage = new Stage "main_stage"
  
  window.robot = new Vehicle
  main_stage.vehicle_layer.add robot.shape
  
  main_stage.test_add rect2
  
  # window.s1 = new PointSensor {x:75, y:75}  
  # window.s2 = new PointSensor {x:200, y:200} 
  window.es = new EdgeSensor {x:20, y:20}
  
  # main_stage.test_add s1
  # main_stage.test_add s2
  main_stage.test_add es
  # main_stage.test_add cir_group
  
  main_stage.kinetic_stage.draw()
  

class window.Stage
  
  constructor: (id) ->
    @container = $("##{id}")
    @kinetic_stage = new Kinetic.Stage {container: id, width: @container.width(), height: @container.height()}
    @vehicle_layer = new Kinetic.Layer()
    @kinetic_stage.add @vehicle_layer
    @test_layer = new Kinetic.Layer()
    @kinetic_stage.add @test_layer
  
  test_add: (shape) => 
    shape = normalize_to_kinetic shape
    @test_layer.add shape
    @kinetic_stage.draw()
  
  draw: () =>
    @kinetic_stage.draw()
    
  
  
  
