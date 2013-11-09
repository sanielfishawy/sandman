$(document).ready -> 
    
  window.main_stage = new Stage {box_id: "main_stage"}
  
  window.sandy = new Vehicle
  main_stage.vehicle_layer.add sandy.shape
  
  window.surface = new CustomShapes::CenterRect {
    name: "surface"
    stroke: "red" 
    strokeWidth: 1
    height: 4*12.to_px()
    width: 4*12.to_px()
  }
  
  main_stage.surface_layer.add surface.shape
  main_stage.zoom(1)
  
  $(sandy.sequencer).on("tick", main_stage.draw)  
  
  

class window.Stage
  
  constructor: (params) ->
    @box_id = params.box_id || error "Stage: I need a box_id. Damn it."
    @box = $("##{@box_id}")
    @box_center_x = @box.width() / 2.0
    @box_center_y = @box.height() / 2.0
    
    @height = params.height || 1000
    @width = params.width || 1000
    @center_x = @width / 2.0
    @center_y = @height / 2.0
    
    
    @kinetic_stage = new Kinetic.Stage {container: @box_id, x:0, y:0, width: 1000, height: 1000}
    
    @surface_layer = new Kinetic.Layer 
    @vehicle_layer = new Kinetic.Layer()
    @test_layer = new Kinetic.Layer()
    
    @layers = [@vehicle_layer, @test_layer, @surface_layer]
    
    @kinetic_stage.add layer for layer in @layers
  
  pan_to_center: => 
    scale = @kinetic_stage.getScale().x
    layer.setOffset x: -@box_center_x/scale, y:-@box_center_y/scale for layer in @layers
    @draw()
  
  zoom: (z) => 
    @kinetic_stage.setScale z
    @pan_to_center()
  
  pan: (x,y) =>
    layer.setOffset x:-x, y:-1 for layer in @layers
    @draw() 
    
  test_add: (shape) => 
    shape = normalize_to_kinetic shape
    @test_layer.add shape
    @kinetic_stage.draw()
  
  draw: () =>
    @kinetic_stage.draw()
  
  setScale: (s) =>
    @kinetic_stage.setScale s
    

# ==========
# = Layers =
# ==========
class window.Layers
  
  constructor: (params={}) -> 
