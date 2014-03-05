# Socket & http server to talk to node socket client on browser.
class SocketIO
  @init: => 
    @api = require "./api"
    @fs = require "fs"
    @http = require "http"
    @url = require "url"
    
    @port = 4000
    @app = @http.createServer(@handle_http_req)
    @io = require('socket.io').listen(@app)
    @io.set('log level', 1)
    @app.listen @port
    @setup_socket_listener()
    
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
  
  @handle_http_req: (req, res) =>
    request = @url.parse(req.url, true)
    path = request.pathname
    
    console.log "Get for #{path}"
    if path.match /\/images/
      img = @fs.readFileSync ".#{path}"
      res.writeHead(200, {'Content-Type': 'image/gif' })
      res.end(img, 'binary')
    
  @handle_api: (data) => 
    callback = (cb_params) => SocketIO.transmit_callback(data.callback_id, cb_params)
    data.params.push callback
    if data.name_space.toLowerCase() is "eyes"
      #forward to the python eyes server
      ClientSocket.call_api(data.name_space, data.method, data.params, callback) 
    else
      @api.exec(data.name_space, data.method, data.params)
  
  @transmit_callback: (callback_id, params) => 
    console.log "SocketIO.transmit_callback: called with callback_id = #{callback_id}"
    @socket.emit("callback", {callback_id: callback_id, params: params})


# Client socket to talk to python socket server e.g. for webcam
class ClientSocket
  @init: => 
    @callbacks = {}
    @net = require('net')
    @port = 12345
    @client = @net.connect({port: @port}, @handle_connected)
    @setup_data_listener()
    
  @setup_data_listener: =>
    @client.on('data', @handle_callback)
    
  @test_callback: (params) =>
    console.log "SocketIO.test_callback params = "
    console.log param

  @handle_connected: (data) => console.log "ClientSocket: connected."

  @handle_callback: (str) => 
    r = JSON.parse(str)
    console.log "ClientSocket.handle_callback: id=#{r.callback_id}"
    @callbacks[r.callback_id] and @callbacks[r.callback_id](r.params)

  @call_api: (name_space, method, params, callback) =>
    console.log "ClientSocket.call_api: #{name_space}.#{method}(#{params})"
    console.log params
    @init() unless @client
    id = (new Date).getTime()
    @callbacks[id] = callback if callback
    @client.write( JSON.stringify {name_space: name_space, method: method, params: params, callback_id: id} )

# ClientSocket.call_api("eyes", "hello", {input_params: "hi eyes"}, ClientSocket.test_callback)

module.exports = {
  client_socket: ClientSocket
  socket_io: SocketIO
  init: SocketIO.init
}
    
