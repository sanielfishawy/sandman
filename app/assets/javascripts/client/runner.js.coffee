$(document).ready -> 
  Runner.init()
  # Runner.seg_circ()
    
  
class window.Runner
  
  @init: => 
    window.main_stage = new Stage {box_id: "main_stage"}

    window.sandy = new Vehicle
    window.main_stage.vehicle_layer.add sandy.shape

    window.surface = Surface.shape()
    main_stage.surface_layer.add window.surface
    
    window.tracks = new Tracks vehicle:sandy 
    
    main_stage.zoom(1)
  
  
  @seg_circ: => 
    r = 200
    h = r*Math.sin(1.to_rad())
    @data = "M #{h/2} #{-r} "
    for ang in [1..360]
      y = h*Math.sin(ang.to_rad())
      x = h*Math.cos(ang.to_rad())
      @data += " l #{x} #{y} "
      
    path = new Kinetic.Path {
      x: 0,
      y: 0,
      data: @data
      fillEnabled: false
      stroke: "red"
      strokeWidth: 1
    }
    
    @axis = "M #{-r} 0 L #{r} 0 M 0 #{r} L 0 #{-r}"
    axis = new Kinetic.Path {
      x: 0,
      y: 0,
      data: @axis
      fillEnabled: false
      stroke: "black"
      strokeWidth: 1
    }
    
    window.main_stage.test_add axis
    
    window.main_stage.test_add path
