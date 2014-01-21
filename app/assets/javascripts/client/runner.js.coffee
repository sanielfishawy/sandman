$(document).ready -> 
  Runner.init()
  
class window.Runner
  
  @init: => 
    window.main_stage = new Stage {box_id: "main_stage"}

    window.sandy = new Vehicle
    window.main_stage.vehicle_layer.add sandy.shape
    
    
    
    Surface.add_shape()
    
    window.tracks = new Tracks vehicle:sandy 
    
    main_stage.zoom(1)
    
    window.algo = new Algorithm(sandy)
    algo.move_forward()
    
    # @line_v()
    
    
    
  
  @line: => 
    scale = main_stage.kinetic_stage.getScale().x
    offset_x = main_stage.test_layer.getOffset().x
    offset_y = main_stage.test_layer.getOffset().y
    line = new Kinetic.Line {
      points: [offset_x, offset_y, offset_x+100, offset_y+100]
      stroke: "red"
    }
    line2 = new Kinetic.Line {
      points: [sandy.shape.getPosition().x, sandy.shape.getPosition().y, sandy.left_sensor.shape.getPosition().x, sandy.left_sensor.shape.getPosition().y]
      stroke: "green"
    }
    main_stage.test_add line
    main_stage.test_add line2

  @line_v: => 
    scale = main_stage.kinetic_stage.getScale().x
    console.log scale
    offset_x = main_stage.test_layer.getOffset().x * scale
    offset_y = main_stage.test_layer.getOffset().y * scale
    start_x = (sandy.shape.getAbsolutePosition().x + offset_x) / scale
    start_y = (sandy.shape.getAbsolutePosition().y + offset_y) / scale
    end_x = (sandy.left_sensor.shape.getAbsolutePosition().x + offset_x) / scale
    end_y = (sandy.left_sensor.shape.getAbsolutePosition().y + offset_y) / scale
    line = new Kinetic.Line {
      points: [start_x, start_y, end_x, end_y]
      stroke: "green"
    }
    main_stage.test_add line
  
  @