$(document).ready -> 
    
  window.main_stage = new Stage "main_stage"
  
  
  # window.sandy = new Vehicle x:10, y:10  
  # main_stage.test_add sandy
  # main_stage.setScale(.25)
  # main_stage.kinetic_stage.draw()
  # $(sandy.sequencer).on("tick", main_stage.draw)  
  
  

class window.Stage
  
  constructor: (id) ->
    @container = $("##{id}")
    @kinetic_stage = new Kinetic.Stage {container: id, width: 2000, height: 2000}
    # @vehicle_layer = new Kinetic.Layer()
    # @kinetic_stage.add @vehicle_layer
    # @test_layer = new Kinetic.Layer()
    # @kinetic_stage.add @test_layer
    
    @surface_layer = new Kinetic.Layer()
    @rect = new Kinetic.Rect {
      x:0
      y:0
      height:640
      width:640
      stroke: "red"
      strokeWidth: 2
      # fill: "red"
      # fillEnabled:true
    }
    @kinetic_stage.add @surface_layer
    @surface_layer.add @rect
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
