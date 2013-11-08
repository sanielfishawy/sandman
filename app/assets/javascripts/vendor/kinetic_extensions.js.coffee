$(document).ready ->
  
  Kinetic.Group.prototype.fire_all_children = (evt) -> s.fire(evt) for s in @.get("Shape")