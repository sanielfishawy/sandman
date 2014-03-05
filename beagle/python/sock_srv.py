import socket 
import sys, signal, os
import json

def handler (signal, frame):
  print "Quitting ever so gracefully."
  socket_handler.close()
  sys.exit(0)
    
signal.signal(signal.SIGINT, handler)

class SocketHandler:
  # Blocking SocketHandler handles one connection at a time and one command on that connection at a time.
  port = 12345
  socket_server = None
  connection = None
  
  def __init__ (self):
    self.get_socket_server()
    self.get_connection()
  
  def get_socket_server (self):
    if (self.socket_server):
      return
      
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('localhost', self.port))
    s.listen(5)
    self.socket_server = s
    print "Eyes server listening on port: " + str(self.port)

  def get_connection (self):
    if (self.connection):
      return 
      
    c = None
    while c is None:
      (c, address) = self.socket_server.accept()
    print "Got a connection"
    self.connection = c
    return c

  def get_command (self):
    cmd = None
    print "Waiting on a command"
    while not cmd:
      data = self.connection.recv(10000)
      if data is "":
        self.__init__()  #lost the connection.
        break
      print("Received raw data: " + data)
      try:
        cmd = json.loads(data)
      except:
        print "Json unable to parse data"
    print "Cmd: " + str(cmd)
    return cmd

  def send (self, r):
    print "Sent response: ", r
    self.connection.send(r)
  
  def close (self):
    if self.connection:
      print "Closing connection"
      self.connection.close()
    if self.socket_server:
      print "Closing socket_server"
      self.socket_server.close()


import eyes

class ApiHandler:
  
  name_spaces = {
    "eyes": eyes
  }
  
  def execute (self, cmd):
    print "Executing: " + str(cmd)
    self.cmd = cmd
    name_space = self.name_spaces[cmd["name_space"]]
    r = getattr(name_space, cmd["method"])(cmd["params"])
    return self.format_response(r)
  
  def format_response (self, r):
    self.response = {"callback_id": self.cmd["callback_id"], "params": r}
    return json.dumps(self.response)
    
    
socket_handler = SocketHandler()
api_handler = ApiHandler()
while True:
  cmd = socket_handler.get_command()
  r = api_handler.execute(cmd)
  socket_handler.send(r)

  

    
  
  