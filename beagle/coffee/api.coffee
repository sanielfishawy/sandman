class Api
  
  @client_socket = require("./socket_io").client_socket
  
  @name_spaces: {
    Led:  require("./bb_led")
    Dsc: require("./stepper").create()
  }
  
  @exec: (name_space, method, params) =>
    @name_spaces[name_space][method].apply(undefined, params)
      
module.exports = {
  name_spaces: Api.name_spaces
  exec: Api.exec
}
