class window.Surface
  
  @add_shape: (stage=Stage.instance) => 
    rect = new CustomShapes::CenterRect {
      name: "surface"
      stroke: "red" 
      strokeWidth: 1
      height: 3.5*12.to_px()
      width: 3.5*12.to_px()
    }
    @surface_shape = rect.shape
    stage.surface_layer.add @surface_shape
    stage.draw()

  @is_out: (point) => 
    pos = @get_shape_pos()
    min_x = pos.x
    min_y = pos.y
    max_x = pos.x + @get_shape_width()
    max_y = pos.y + @get_shape_height()
    point.x < min_x or point.x > max_x or point.y < min_y or point.y > max_y
  
  @get_shape_pos: => @shape_pos || @shape_pos = @surface_shape.getAbsolutePosition()
  @get_shape_height: => @shape_height || @shape_height = @surface_shape.getHeight()  
  @get_shape_width: => @shape_width || @shape_width = @surface_shape.getWidth()  