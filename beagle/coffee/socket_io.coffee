class SocketIO
  @init: => 
    @port = 4000
    @app = require('http').createServer()
    @io = require('socket.io').listen(@app)
    @io.set('log level', 1)
    @app.listen @port
    @setup_socket_listener()
    @api = require "./api"
    
  @setup_socket_listener: =>
    @io.sockets.on(
      'connection'
      (socket) =>
        @socket = socket
        socket.emit('connected', { port: @port })
        socket.on(
          'Api'
          (data) => @handle_api(data)
        )
    )

  @handle_api: (data) => 
    callback = (cb_params) => SocketIO.transmit_callback(data.callback_id, cb_params)
    data.params.push callback
    @api.exec(data.name_space, data.method, data.params)
  
  @transmit_callback: (callback_id, params) => 
    console.log "SocketIO.transmit_callback: called with callback_id = #{callback_id}"
    @socket.emit("callback", {callback_id: callback_id, params: params})

module.exports = {
  socket_io: SocketIO
  init: SocketIO.init
}
    
