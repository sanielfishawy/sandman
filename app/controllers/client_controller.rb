class ClientController < ApplicationController
  
  def index
    ENV["bot_port"] = "4000"
    if params[:ip].blank?
      ENV["bot_ip_addr"] = "127.0.0.1"
    elsif params[:ip] == "usb"
      ENV["bot_ip_addr"] = "192.168.7.2"
    else
      ENV["bot_ip_addr"] = "192.168.1." + params[:ip]
    end
  end
  
end
