

###
#===========================================================================================================



 .d8888b.   .d88888b.  888888b.          d8888     .d8888b.  8888888888 8888888b.  888     888 8888888888 8888888b.
d88P  Y88b d88P" "Y88b 888  "88b        d88888    d88P  Y88b 888        888   Y88b 888     888 888        888   Y88b
Y88b.      888     888 888  .88P       d88P888    Y88b.      888        888    888 888     888 888        888    888
 "Y888b.   888     888 8888888K.      d88P 888     "Y888b.   8888888    888   d88P Y88b   d88P 8888888    888   d88P
    "Y88b. 888     888 888  "Y88b    d88P  888        "Y88b. 888        8888888P"   Y88b d88P  888        8888888P"
      "888 888     888 888    888   d88P   888          "888 888        888 T88b     Y88o88P   888        888 T88b
Y88b  d88P Y88b. .d88P 888   d88P  d8888888888    Y88b  d88P 888        888  T88b     Y888P    888        888  T88b
 "Y8888P"   "Y88888P"  8888888P"  d88P     888     "Y8888P"  8888888888 888   T88b     Y8P     8888888888 888   T88b



#===========================================================================================================
###



############################################################################################################
njs_path                  = require 'path'
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
#...........................................................................................................
new_app                   = require 'express'
njs_http                  = require 'http'
new_sio_server            = require 'socket.io'
new_router                = require 'socket.io-events'


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
@new_server = ( port = 3000 ) ->
  app         = new_app()
  #.........................................................................................................
  app.use '/public', new_app.static njs_path.join __dirname, '../public'
  app.use '/common', new_app.static njs_path.join __dirname, '../common'
  app.get '/', @_get_monitor()
  router      = new_router()
  #.........................................................................................................
  http_server = njs_http.Server app
  sio_server  = new_sio_server http_server
  sio_server.use router
  #.........................................................................................................
  R =
    '%app':                 app
    '%http-server':         http_server
    '%sio-server':          sio_server
    '%router':              router
    'port':                 port
    'client-count':         0
  #---------------------------------------------------------------------------------------------------------
  router.on '*', ( socket, event, next ) =>
    [ type, data, ] = event
    help 'received-event:', type, data ? './.'
    @emit_news R, 'received-event', { 'type': type, }
    next()
  #.........................................................................................................
  router.on 'helo', ( socket, event, next ) =>
    client_id = @get_client_id R, socket
    @emit         R, socket, 'helo', { 'client-id': client_id, }
    ### !!! ###
    # @emit_news    R, {}
    debug '©Gp1qF', event
    next()
  #---------------------------------------------------------------------------------------------------------
  sio_server.on 'connection', ( socket ) =>
    R[ 'client-count' ] += 1
    urge "#{R[ 'client-count' ]} clients connected"
    @emit_news R, 'client-count', { 'value': R[ 'client-count' ], 'delta': +1, }
    # #.......................................................................................................
    # greet = =>
    #   debug '©wB1Ef', "/: emitting greeting"
    #   SIO.emit 'news', "welcome to our new user #{client_id}"
    #   # for idx in [ 0 .. 10 ]
    #   socket.emit 'news', "your client ID is #{client_id}"
    # setTimeout greet, 1500
    #.......................................................................................................
    socket.on 'disconnect', =>
      R[ 'client-count' ] -= 1
      warn "#{R[ 'client-count' ]} clients connected"
      @emit_news R, 'client-count', { 'value': R[ 'client-count' ], 'delta': -1, }
    #.......................................................................................................
    return null
  #.........................................................................................................
  return R


#-----------------------------------------------------------------------------------------------------------
@on = ( me, matcher, handler ) ->
  return router.on matcher, handler

#-----------------------------------------------------------------------------------------------------------
# @new_event  = ( me, name, data... ) -> [ name, data, ]
@get_app    = ( me ) -> me[ '%app' ]
@get_router = ( me ) -> me[ '%router' ]

#-----------------------------------------------------------------------------------------------------------
@emit = ( me, socket, type, data ) ->
  socket.emit type, data

#-----------------------------------------------------------------------------------------------------------
@emit_news  = ( me, topic, data ) ->
  me[ '%sio-server' ].emit 'news', topic, data

#-----------------------------------------------------------------------------------------------------------
@get_client_id = ( me, socket ) ->
  ### http://stackoverflow.com/a/24232050/256361 ###
  ### first form when used in a Socket.IO handler, second form when used in a router's handler: ###
  return socket.client?.id ? socket.sock.client.id


#---------------------------------------------------------------------------------------------------------
@_get_monitor = =>
  return ( request, response ) =>
    headers =
      'Access-Control-Allow-Origin':  '*'
      'Content-Type':                 'text/html; charset=utf-8'
    response.writeHead 200, headers
    response.write TEMPLATES.monitor()
    #.......................................................................................................
    response.end()

#-----------------------------------------------------------------------------------------------------------
@serve = ( me ) ->
  # me[ '%http-server' ] = me[ '%app' ].listen me[ 'port' ], ->
  me[ '%http-server' ] = me[ '%http-server' ].listen me[ 'port' ], ->
    help "server process running on Node v#{process.versions[ 'node' ]}"
    { address: host, family, port, } = me[ '%http-server' ].address()
    help "SoBa ソバ Server listening to http://#{host}:#{port} (#{family})"


############################################################################################################
unless module.parent?
  SOBA    = @
  sb      = SOBA.new_server()
  SOBA.serve sb
  app     = SOBA.get_app sb
  router  = SOBA.get_router sb
  router.on 'helo', ( socket, P, next ) ->
    debug '©Gp1qF', P
    next()
  # http_server               = ( require 'http'      ).Server app
  # SIO                       = ( require 'socket.io' ) http_server
  # port                      = 3000
  # app.get '/', @_get_monitor()
  # http_server = http_server.listen port, ->
  #   # debug '©yXWeN', http_server.address()
  #   help "http_server process running on Node v#{process.versions[ 'node' ]}"
  #   { address: host, port, } = http_server.address()
  #   help "SoBa ソバ Server listening to http://#{host}:#{port}"





