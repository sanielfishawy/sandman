class window.Conversion
  @px_per_inch = 15
  

Number.prototype.to_px = -> @*Conversion.px_per_inch
Number.prototype.to_inch = -> 1.0*@/Conversion.px_per_inch

# Syntactic sugar for adding our objects which typically have a shape function to a Kinetic stage.
window.normalize_to_kinetic = (obj) -> 
  if typeof obj.shape is "function" then return obj.shape() 
  if obj.shape then return obj.shape
  return obj

window.n_to_k = normalize_to_kinetic