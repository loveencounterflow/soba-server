


############################################################################################################
# njs_path                  = require 'path'
# njs_fs                    = require 'fs'
#...........................................................................................................
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
# badge                     = 'ソバ/TEMPLATES'
# log                       = TRM.get_logger 'plain',     badge
# info                      = TRM.get_logger 'info',      badge
# whisper                   = TRM.get_logger 'whisper',   badge
# alert                     = TRM.get_logger 'alert',     badge
# debug                     = TRM.get_logger 'debug',     badge
# warn                      = TRM.get_logger 'warn',      badge
# help                      = TRM.get_logger 'help',      badge
# urge                      = TRM.get_logger 'urge',      badge
#...........................................................................................................
TEACUP                    = require 'coffeenode-teacup'
# STYLUS                    = require 'stylus'
# #...........................................................................................................
# as_css                    = STYLUS.render.bind STYLUS
# style_route               = njs_path.join __dirname, '../public/mingkwai-typesetter.styl'
# css                       = as_css njs_fs.readFileSync style_route, encoding: 'utf-8'


#===========================================================================================================
# TEACUP NAMESPACE ACQUISITION
#-----------------------------------------------------------------------------------------------------------
for name_ of TEACUP
  eval "#{name_} = TEACUP[ #{rpr name_} ]"

#-----------------------------------------------------------------------------------------------------------
@monitor = ->
  #.........................................................................................................
  return render =>
    DOCTYPE 5
    HTML =>
      HEAD =>
        META charset: 'utf-8'
        TITLE 'SoBa ソバ Monitor'
        LINK rel: 'shortcut icon', href: '/public/favicon.ico?v6'
        LINK rel: 'stylesheet', href: '/common/html5doctor-css-reset.css?v6'
        # LINK rel: 'stylesheet', href: '/public/mingkwai-typesetter.css?v6'
        SCRIPT type: 'text/javascript', src: '/common/jquery-2.1.3.js'
        # SCRIPT type: 'text/javascript', src: '/common/css-regions-polyfill.min.js'
        # SCRIPT src: 'http://code.jquery.com/jquery-1.11.1.js'
        SCRIPT src: '/socket.io/socket.io.js'
        STYLE """
          body {
            background-image:         url(./public/soba-logo.png);
            background-repeat:        no-repeat;
            padding:                  1em;
            background-attachment:    fixed;
            background-size:          100%;
            -webkit-background-size:  100%;
          }
          #client-id {
            // text-align:         right;
            padding:            1em;
            margin-top:         1em;
            margin-bottom:      1em;
            background-color:   rgba( 255, 255, 255, 0.5 );
            width:              80%;
            min-height:         1em;
            border: 1px solid red;
          }
          #news {
            padding:            1em;
            margin-top:         1em;
            margin-bottom:      1em;
            background-color:   rgba( 255, 255, 255, 0.5 );
            width:              80%;
            min-height:         1em;
            border: 1px solid blue;
          }
          """
      #=====================================================================================================
      BODY =>
        H1 "SoBa ソバ Monitor"
        DIV '#client-id'
        DIV '#news'
        COFFEESCRIPT =>
          ( $ 'document' ).ready ->
            log     = console.log.bind console
            rpr     = JSON.stringify.bind JSON
            socket  = io()
            #.................................................................................................
            emit = ( type, data ) ->
              publish_news 'sent-event', { type, data, }
              socket.emit type, data
            #.................................................................................................
            scroll_to_bottom = ->
              # log '©Rafbc', ( $ '#bottom' ).offset
              ( $ 'html, body' ).stop().animate { scrollTop: ( $ '#bottom' ).offset().top }, 500
            #.................................................................................................
            publish_news = ( topic, data ) ->
              # log '©4363t2', rpr ( x for x in arguments)
              switch topic
                #.............................................................................................
                when 'received-event'
                  { type, data, } = data
                  if data? then               message = "server received: type #{rpr type}; #{rpr data}"
                  else                        message = "server received: type #{rpr type}"
                #.............................................................................................
                when 'updated-client-id' then message = "updated client ID: #{rpr data}"
                #.............................................................................................
                when 'client-count'
                  { value, delta, } = data
                  if delta > 0 then           message = "client count: up to #{value}"
                  else                        message = "client count: down to #{value}"
                #.............................................................................................
                when 'sent-event'
                  { type, data, } = data
                  if data? then               message = "client sent: type #{rpr type}; #{rpr data}"
                  else                        message = "client sent: type #{rpr type}"
                #.............................................................................................
                else                          message = "topic: #{topic}, data: #{rpr data}"
              #...............................................................................................
              ( $ '#news' ).append ( $ '<div></div>' ).text message
              scroll_to_bottom()
            #.................................................................................................
            publish_client_id = ( data ) ->
              # log '©kl62m', rpr ( x for x in arguments)
              ( $ '#client-id' ).append ( $ '<div></div>' ).text "Client-ID: #{data[ 'client-id' ]}"
              publish_news 'updated-client-id', data[ 'client-id' ]
              scroll_to_bottom()
            #.................................................................................................
            socket.on 'news', publish_news
            socket.on 'helo', publish_client_id
            socket.on 'connect', =>
              emit 'helo'
              # emit 'foo', 42
              # emit 'bar', { baz: true, }
        #===================================================================================================
        DIV '#bottom'
