class window.Surface
  
  @shape: => 
    s = new CustomShapes::CenterRect {
      name: "surface"
      stroke: "red" 
      strokeWidth: 1
      height: 4*12.to_px()
      width: 4*12.to_px()
    }
    s.shape