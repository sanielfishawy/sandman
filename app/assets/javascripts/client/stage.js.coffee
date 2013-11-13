# =========
# = Stage =
# =========
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
    
    @surface_layer = new Kinetic.Layer name: "surface_layer"
    @vehicle_layer = new Kinetic.Layer name: "vehicle_layer"
    @test_layer = new Kinetic.Layer name: "test_layer"
    
    @layers = [@vehicle_layer, @test_layer, @surface_layer]
    
    @kinetic_stage.add layer for layer in @layers
    @add_redraw_handlers()
    
  add_redraw_handlers: =>
    $(document).on("after_move", @draw)
    $(document).on("sensor_change", @draw)
  
  pan_to_center: => 
    scale = @kinetic_stage.getScale().x
    layer.setOffset x: -@box_center_x/scale, y:-@box_center_y/scale for layer in @kinetic_stage.children
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
    
