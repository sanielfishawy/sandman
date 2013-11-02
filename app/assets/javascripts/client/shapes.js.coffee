class window.CustomShapes
  
  @center_rect: (params={}) => 
    center_x = params.center_x || 5
    center_y = params.center_y || 5
    params["x"] = center_x - (params.width / 2.0)
    params["y"] = center_y - (params.height / 2.0)  
    new Kinetic.Rect params