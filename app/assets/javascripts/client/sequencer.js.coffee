class window.Sequencer
  
  @sequence: [
    "move"
    "sense"
    ]
  
  constructor: (params={}) ->
    @clock_period_ms = params.clock_period_ms || 30
    @num_sequence_actions = Sequencer.sequence.length
  
  clock_tick: => 
    if @current_clock is undefined then @current_clock = 0 else @current_clock++ 
    @current_action = Sequencer.sequence[@current_clock % @num_sequence_actions]
    $(@).trigger "tick"
    $(@).trigger @current_action if @current_action
  
  start: => 
    @clock_interval = setInterval(@clock_tick, @clock_period_ms)
  
  stop: => 
    clearInterval @clock_interval if @clock_interval
    @clock_interval = false
  
  is_running: => if @clock_interval then true else false
  
    
    
