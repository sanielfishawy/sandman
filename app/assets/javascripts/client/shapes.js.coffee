class window.CustomShapes

# ==============
# = CenterRect =
# ==============
class CustomShapes::CenterRect
  constructor: (params={}) -> 
    @center_x = normalize_to_num(params.x, 300)
    @center_y = normalize_to_num(params.y, 300)
    params.width ||= 100
    params.height ||= 50
    params.x = Math.round(@center_x - (params.width / 2.0))
    params.y = Math.round(@center_y - (params.height / 2.0)) 
    params.stroke ||= "black"
    params.strokeWidth ||= 1
    @shape = new Kinetic.Rect params

# =========
# = Arrow =
# =========
class CustomShapes::Arrow
  constructor: (params={}) ->
    fromx = normalize_to_num(params.tail_x, 0).to_px()
    tox = normalize_to_num(params.head_x, 10).to_px()
    fromy = normalize_to_num(params.tail_y, 0).to_px()
    toy = normalize_to_num(params.head_y, 10).to_px()
    headlen = params.head_len || 0.5.to_px()
    params.stroke ||= "black"
    params.strokeWidth ||= 1
    params.lineJoine ||= "round"
    angle = Math.atan2(toy-fromy,tox-fromx);
    params.points = [fromx, fromy, tox, toy, tox-headlen*Math.cos(angle-Math.PI/6),toy-headlen*Math.sin(angle-Math.PI/6),tox, toy, tox-headlen*Math.cos(angle+Math.PI/6),toy-headlen*Math.sin(angle+Math.PI/6)]
    @shape = new Kinetic.Line params
