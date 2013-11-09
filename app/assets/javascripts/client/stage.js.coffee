$(document).ready -> 
    
  window.main_stage = new Stage {box_id: "main_stage"}
  
  
  # window.sandy = new Vehicle x:10, y:10  
  # main_stage.test_add sandy
  # main_stage.setScale(.25)
  # main_stage.kinetic_stage.draw()
  # $(sandy.sequencer).on("tick", main_stage.draw)  
  
  

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
    
    
    @kinetic_stage = new Kinetic.Stage {container: @box_id, x:0, y:0, width: 5000, height: 5000}
    # @vehicle_layer = new Kinetic.Layer()
    # @kinetic_stage.add @vehicle_layer
    # @test_layer = new Kinetic.Layer()
    # @kinetic_stage.add @test_layer
    
    @surface_layer = new Kinetic.Layer 
    @rect = new CustomShapes::CenterRect {
      x:0
      y:0
      height:100
      width:100
      stroke: "red"
      strokeWidth: 2
      # fill: "red"
      # fillEnabled:true
    }
    @kinetic_stage.add @surface_layer
    @surface_layer.add @rect.shape
    @draw()
  
  pan_to_center: => 
    scale = @kinetic_stage.getScale().x
    @surface_layer.setOffset x: -@box_center_x/scale, y:-@box_center_y/scale
    @draw()
  
  zoom: (z) => 
    @kinetic_stage.setScale z
    @pan_to_center()
  
  pan: (x,y) =>
    @surface_layer.setOffset x:-x, y:-1
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
