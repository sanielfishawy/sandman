# api = require("./api")
# dsd = api.dsc.dsd
# dsd = require("./stepper").create().dsd
# dsd.set_pin(0,"step", 1)



global.dsc = require("./stepper").create()
global.dsd = dsc.dsd
# global.pin = dsd.pins[48]
# pin.set_val("0")
dsd.set_pin(0,"step", 1)
# dsd.test_set_val()

# rpm = 100
# console.log "interval for rpm=#{rpm} => #{dsd.interval_from_rpm(rpm)}"
# 
# t0 = new Date
# n = 1000
# for i in [1..n]
#   pin.set_val("0")
#   pin.set_val("1")
# d_t = (new Date) - t0
# console.log "Freewheeling rate: #{n} pulses in #{d_t}ms = #{1000.0*n/d_t} pulses/sec"
# 
# class EventPulse
#   @start: =>  
#     @n = 1000
#     @timer = setInterval(@pulse_and_count, 1)
#     @t0 = new Date
#   
# 
#   @pulse_and_count = =>
#     @c ||= 0
#     pin.set_val("0")
#     pin.set_val("1")
#     @c++
#     @done() if @c is @n
# 
#   @done: => 
#     d_t = (new Date) - @t0
#     clearInterval @timer
#     console.log "Event driven rate: #{@n} pulses in #{d_t}ms = #{1000.0*@n/d_t} pulses/sec"
#   
# EventPulse.start() 
  