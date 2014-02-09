class Config
  @init: =>
    console.log "Config.init..."
    @sh = require "execSync"
    @determine_emulated()
    
  @determine_emulated: => 
    @os = @sh.exec("uname").stdout.trim()
    @emulated = if @os.match /darwin/i then true else false
    console.log "Config.emulated = #{@emulated} | (os = #{@os})"

Config.init()

module.exports = {
  Config: Config
  emulated: Config.emulated
}




