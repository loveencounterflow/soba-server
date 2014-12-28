


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
        # STYLE css
      #=====================================================================================================
      BODY =>
        SCRIPT src: 'http://code.jquery.com/jquery-1.11.1.js'
        SCRIPT src: '/socket.io/socket.io.js'
        H1 "SoBa ソバ Monitor"
        DIV '#news'
        COFFEESCRIPT =>
          log     = console.log.bind console
          socket  = io()
          socket.on 'news', ( message ) ->
            ( $ '#news' ).append ( $ '<div></div>' ).text message
            ( $ 'html, body' ).stop().animate { scrollTop: ( $ '#bottom' ).offset().top }, 2000
        #===================================================================================================
        DIV '#bottom'
