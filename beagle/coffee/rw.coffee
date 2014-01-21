fs = require("fs")

emulated = false
set_emulated = (val) -> emulated = val
  
sync_write = (path, text) -> 
  console.log "rw.write: writing - path: #{path} | text:#{text}"
  return if emulated
  
  try
    write_buffer = new Buffer(text)
  catch
    debugger
  
  fs.open(path, 'w', (err, fd) =>
    throw err if err
    bytes = fs.writeSync(fd, write_buffer, 0, write_buffer.length, null)
    console.log "rw.write: wrote - path: #{path} | text:#{text} | #{bytes} bytes"
  )
  
module.exports = {
  sync_write: sync_write
  set_emulated: set_emulated
}
