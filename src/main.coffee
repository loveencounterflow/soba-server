

###
#===========================================================================================================



 .d8888b.  8888888  .d88888b.      .d8888b.  8888888888 8888888b.  888     888 8888888888 8888888b.
d88P  Y88b   888   d88P" "Y88b    d88P  Y88b 888        888   Y88b 888     888 888        888   Y88b
Y88b.        888   888     888    Y88b.      888        888    888 888     888 888        888    888
 "Y888b.     888   888     888     "Y888b.   8888888    888   d88P Y88b   d88P 8888888    888   d88P
    "Y88b.   888   888     888        "Y88b. 888        8888888P"   Y88b d88P  888        8888888P"
      "888   888   888     888          "888 888        888 T88b     Y88o88P   888        888 T88b
Y88b  d88P   888   Y88b. .d88P    Y88b  d88P 888        888  T88b     Y888P    888        888  T88b
 "Y8888P"  8888888  "Y88888P"      "Y8888P"  8888888888 888   T88b     Y8P     8888888888 888   T88b



#===========================================================================================================
###



############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
# TEXT                      = require 'coffeenode-text'
# TYPES                     = require 'coffeenode-types'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'ソバ/SERVER'
info                      = TRM.get_logger 'info',    badge
alert                     = TRM.get_logger 'alert',   badge
debug                     = TRM.get_logger 'debug',   badge
warn                      = TRM.get_logger 'warn',    badge
urge                      = TRM.get_logger 'urge',    badge
whisper                   = TRM.get_logger 'whisper', badge
help                      = TRM.get_logger 'help',    badge
#...........................................................................................................
TEMPLATES                 = require './TEMPLATES'
app                       = ( require 'express'   )()
server                    = ( require 'http'      ).Server app
SIO                       = ( require 'socket.io' ) server
port                      = 3000
client_count              = 0
#...........................................................................................................
router                    = ( require 'socket.io-events' )()



# ### Socket.io namespace ###
# SIO_GRAPEVINE = SIO.of '/grapevine'

# #-----------------------------------------------------------------------------------------------------------
# SIO_GRAPEVINE.on 'connection', ( socket ) ->
#   doc = null
#   urge "/grapevine: a user connected"
#   greet = ->
#     debug '©wB1Ef', "/grapevine: emitting greeting"
#     SIO_GRAPEVINE.emit 'news', 'welcome to our new grapevine user!'
#   setTimeout greet, 1500


#-----------------------------------------------------------------------------------------------------------
router.on '*', ( socket, P, next ) =>
  [ name, message, ] = P
  help 'event:', name, ( message ? './.' )
  next()

#-----------------------------------------------------------------------------------------------------------
router.on 'gimme-json', ( socket, P, next ) =>
  help 'gimme-json'
  [ name, ] = P
  ### first form when used in a Socket.IO handler, second form when used in a router's handler: ###
  client_id = socket.client?.id ? socket.sock.client.id
  value     = { 'foo': 42, 'bar': true, 'client-id': client_id, }
  socket.emit 'heres-json', value
  next()

#-----------------------------------------------------------------------------------------------------------
SIO.use router

#-----------------------------------------------------------------------------------------------------------
SIO.on 'connection', ( socket ) ->
  client_count += 1
  urge "#{client_count} clients connected"
  ### http://stackoverflow.com/a/24232050/256361 ###
  client_id = socket.client.id
  #.........................................................................................................
  greet = ->
    debug '©wB1Ef', "/: emitting greeting"
    SIO.emit 'news', "welcome to our new user #{client_id}"
    # for idx in [ 0 .. 10 ]
    socket.emit 'news', "your client ID is #{client_id}"
  setTimeout greet, 1500
  #.........................................................................................................
  socket.on 'disconnect', ->
    client_count -= 1
    warn "#{client_count} clients connected"
  #.........................................................................................................
  return null

#---------------------------------------------------------------------------------------------------------
app.get '/', do =>
  return ( request, response ) =>
    headers =
      'Access-Control-Allow-Origin':  '*'
      'Content-Type':                 'text/html; charset=utf-8'
    response.writeHead 200, headers
    response.write TEMPLATES.monitor()
    #.......................................................................................................
    response.end()

#-----------------------------------------------------------------------------------------------------------
@serve = ->
  # { port: port, origins: '*:*', }
  server = server.listen port, ->
    # debug '©yXWeN', server.address()
    help "server process running on Node v#{process.versions[ 'node' ]}"
    { address: host, port, } = server.address()
    help "SoBa ソバ Server listening to http://#{host}:#{port}"


############################################################################################################
unless module.parent?
  @serve()



