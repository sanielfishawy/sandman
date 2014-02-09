class window.SocketIO
  @init: => 
    @callbacks = {}
    @socket = io.connect("http://#{Config.bot_ip_addr()}:#{Config.bot_port()}")
    @socket.on('connected', @handle_connected)
    @socket.on('callback', @handle_callback)
    # @call_api("Dsc", "hello", ["world"], @test_callback)
    # @call_api("Dsc", "rotate", ["left", 10], @test_callback)
  
  @test_callback: (params) =>
    console.log "SocketIO.test_callback params = ..."
    console.log params
    
  @handle_connected: (data) => 
    console.log "SocketIO: connected..."
    console.log data
  
  @handle_callback: (data) => 
    console.log "SocketIO.handle_callback: id=#{data.callback_id}"
    @callbacks[data.callback_id] and @callbacks[data.callback_id](data.params)
  
  @call_api: (name_space, method, params, callback) =>
    console.log "SocketIO.call_api: params="
    console.log params
    @init() unless @socket
    id = (new Date).getTime()
    @callbacks[id] = callback if callback
    @socket.emit("Api", {name_space: name_space, method: method, params: params, callback_id: id})
    