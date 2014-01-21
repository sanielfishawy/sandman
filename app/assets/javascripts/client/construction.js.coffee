# A method for drawing temporary construction lines etc 

class window.Construction
  
  @add_line: (point1, point2, stage=Stage.instance, params={}) => 
    params.stroke ||= "red"
    params.strokeWidth ||= 1
    
    point1 = stage.adjust_point_for_offset point1
    point2 = stage.adjust_point_for_offset point2
    params.points = [point1.x, point1.y, point2.x, point2.y]
    
    
    stage.construction_layer.add new Kinetic.Line params
    stage.draw()
  
  @clear: (stage=Stage.instance) => 
    stage.construction_layer.destroyChildren()
    stage.draw()