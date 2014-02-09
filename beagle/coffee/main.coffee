global.Dsc = require("./stepper").create()

c.set_step_resolution(2, 4)

seq_n = 0

sequence = [
  {act: "rotate", dir: "right", n:10}
  {act: "rotate", dir: "left", n:10}
  {act: "move", dir: "forward", n:10}
  {act: "move", dir: "back", n:10}
]

execute = =>
  return if seq_n >= sequence.length
  step = sequence[seq_n]
  seq_n++
  if step.act is "rotate"
    c.rotate(step.dir, step.n, execute)
  else
    c.move(step.dir, step.n, execute)

execute()
# setTimeout(c.dsd.stop,  2000)

# setInterval(
#   ->
#   5000
# )
# debugger
console.log "done"