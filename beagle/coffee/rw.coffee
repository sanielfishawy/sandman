fs = require("fs")
config = require("./config")
  
sync_write = (path, text) -> 
  console.log "rw.write: writing - path: #{path} | text:#{text}"
  if config.emulated
    console.log "RW.sync_write: Not writing becuase Config.emulated = true"
    return
  
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
}
