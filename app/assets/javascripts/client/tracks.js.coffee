class window.Tracks
  
  constructor: (params= {}) ->
    @vehicle = params.vehicle || throw "Tracks: I need a vehicle. Damn it."
    @k_vehicle = n_to_k @vehicle
    @tracks_layer = new Kinetic.Layer name: "tracks_layer"
    @k_vehicle.getStage().add @tracks_layer
    @tracks_layer.moveToBottom()
    @path_data = ""
    @add_event_handlers()
  
  add_event_handlers: => 
    $(document).on("after_move", @handle_after_move)
  
  handle_after_move: =>
    @add_vehicle_position_to_path()
    @remove_path_shape()
    @add_path_shape()
    @path.draw()
    
  add_vehicle_position_to_path: =>
    @path_data += if @path_data.is_blank() then "M " else "L "
    @path_data += "#{@k_vehicle.getPosition().x} #{@k_vehicle.getPosition().y} "
    
  add_path_shape: => 
    @path = new Kinetic.Path {
      x: 0
      y: 0
      data: @path_data
      stroke: "tan"
      strokeWidth: 4
    }
    @tracks_layer.add @path
    window.main_stage.draw()
  
  remove_path_shape: => @tracks_layer.destroyChildren()
    
  clear_path_data: => @path_data = ""
  
  reset_tracks: =>
    @clear_path_data()
    @remove_path_shape()
  
  