class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :sprockets_js_erb_cache_bust
  
  # GARF This may have performance issues
  # Make sprockets process all js.erb files by changing a timestamp comment at the top of the file.
  # From my experiments touching the file in the filesystem was not enough there had to be a change 
  def sprockets_js_erb_cache_bust
    do_sprockets_cache_bust(:time_stamp)
  end
  
  def sprockets_js_erb_cache_bust_cleanup
    do_sprockets_cache_bust(:clean_up)
  end
  
  def do_sprockets_cache_bust(action)
    path = File.join(Rails.root, "app", "assets", "javascripts", "client", "*.js.coffee.erb")
    paths = Dir.glob path
    paths.each{|path| action == :clean_up ? remove_time_stamp(path) : add_time_stamp(path)}
  end
  
  # Change the timestamp at the top of the file. 
  def add_time_stamp(path)
    logger.debug "sprockets cache busting: #{File.basename path}"
    lines = File.readlines path
    lines.slice!(0) if lines.first.match(/^#=Timestamp/)
    lines = ["#=Timestamp #{Time.now}\n"] + lines
    File.open(path, "w") do |f|
      lines.each{|l| f.write l}
    end
  end
  
  def remove_time_stamp(path)
    lines = File.readlines path
    lines.slice!(0) if lines.first.match(/^#=Timestamp/)
    File.open(path, "w") do |f|
      lines.each{|l| f.write l}
    end
  end
  
end
