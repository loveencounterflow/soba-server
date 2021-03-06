// Generated by CoffeeScript 1.8.0

/*
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
 */

(function() {
  var SOBA, TEMPLATES, TRM, alert, app, badge, debug, help, info, new_app, new_router, new_sio_server, njs_fs, njs_http, njs_path, router, rpr, sb, urge, warn, whisper,
    __slice = [].slice;

  njs_path = require('path');

  njs_fs = require('fs');

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = 'ソバ/SERVER';

  info = TRM.get_logger('info', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  urge = TRM.get_logger('urge', badge);

  whisper = TRM.get_logger('whisper', badge);

  help = TRM.get_logger('help', badge);

  TEMPLATES = require('./TEMPLATES');


  /* `express` and `socket.io` take quite a while to load, so we issue a confirmational message: */

  help("setting up SoBa ソバ Server");

  new_app = require('express');

  njs_http = require('http');

  new_sio_server = require('socket.io');

  new_router = require('socket.io-events');

  this.new_server = function(port) {
    var R, app, http_server, router, sio_server;
    if (port == null) {
      port = 3000;
    }
    app = new_app();
    app.use('/public', new_app["static"](njs_path.join(__dirname, '../public')));
    app.use('/common', new_app["static"](njs_path.join(__dirname, '../common')));
    app.get('/', this._view_monitor());
    app.get('/restart', this._view_restart());
    router = new_router();
    http_server = njs_http.Server(app);
    sio_server = new_sio_server(http_server);
    sio_server.use(router);
    R = {
      '%app': app,
      '%http-server': http_server,
      '%sio-server': sio_server,
      '%router': router,

      /* TAINT make configurable */
      'verbose': false,
      'port': port,
      'client-count': 0
    };
    router.on('*', (function(_this) {
      return function(socket, event, next) {
        var data, type;
        type = event[0], data = event[1];
        if (R['verbose']) {
          help('received-event:', type, data != null ? data : './.');
        }
        _this.emit_news(R, 'received-event', {
          'type': type
        });
        return next();
      };
    })(this));
    router.on('helo', (function(_this) {
      return function(socket, event, next) {
        var client_id;
        client_id = _this.get_client_id(R, socket);
        _this.emit(R, socket, 'helo', {
          'client-id': client_id
        });

        /* !!! */
        debug('©Gp1qF', event);
        return next();
      };
    })(this));
    router.on('news', (function(_this) {
      return function(socket, event, next) {
        _this.emit_news.apply(_this, [R].concat(__slice.call(event)));
        return next();
      };
    })(this));
    sio_server.on('connection', (function(_this) {
      return function(socket) {
        R['client-count'] += 1;
        urge("" + R['client-count'] + " clients connected");
        _this.emit_news(R, 'client-count', {
          'value': R['client-count'],
          'delta': +1
        });
        socket.on('disconnect', function() {
          R['client-count'] -= 1;
          warn("" + R['client-count'] + " clients connected");
          return _this.emit_news(R, 'client-count', {
            'value': R['client-count'],
            'delta': -1
          });
        });
        return null;
      };
    })(this));
    return R;
  };

  this.on = function(me, matcher, handler) {
    return router.on(matcher, handler);
  };

  this.get_app = function(me) {
    return me['%app'];
  };

  this.get_router = function(me) {
    return me['%router'];
  };

  this.get_sio_server = function(me) {
    return me['%sio-server'];
  };

  this.emit = function(me, socket, type, data) {
    socket.emit(type, data);
    if (me['verbose']) {
      return help("emitted " + (rpr(type)) + "; " + (rpr(data)));
    }
  };

  this.emit_news = function(me, type, topic, data) {
    var arity;
    switch (arity = arguments.length) {
      case 3:
        data = topic;
        topic = type;
        type = 'news';
        break;
      case 4:
        null;
        break;
      default:
        throw new Error("expected 3 or 4 arguments, got " + arity);
    }
    return (this.get_sio_server(me)).emit(type, [topic, data]);
  };

  this.get_client_id = function(me, socket) {

    /* http://stackoverflow.com/a/24232050/256361 */

    /* first form when used in a Socket.IO handler, second form when used in a router's handler: */
    var _ref, _ref1;
    return (_ref = (_ref1 = socket.client) != null ? _ref1.id : void 0) != null ? _ref : socket.sock.client.id;
  };

  this._view_monitor = (function(_this) {
    return function() {
      return function(request, response) {
        var headers;
        headers = {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'text/html; charset=utf-8'
        };
        response.writeHead(200, headers);
        response.write(TEMPLATES.monitor());
        return response.end();
      };
    };
  })(this);

  this._view_restart = (function(_this) {
    return function() {
      return function(request, response) {
        var headers, route;
        headers = {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'text/plain; charset=utf-8'
        };
        response.writeHead(200, headers);
        response.write("restarting");
        response.end();
        urge("received restart signal");
        route = '/tmp/inode-bridge.txt';
        return process.exit();
      };
    };
  })(this);

  this.serve = function(me) {
    var _ref;
    me = (_ref = me['%soba-server']) != null ? _ref : me;
    return me['%http-server'] = me['%http-server'].listen(me['port'], function() {
      var family, host, port, _ref1;
      help("SoBa ソバ Server running on Node v" + process.versions['node']);
      _ref1 = me['%http-server'].address(), host = _ref1.address, family = _ref1.family, port = _ref1.port;
      return help("SoBa ソバ Server listening to http://" + host + ":" + port + " (" + family + ")");
    });
  };

  if (module.parent == null) {
    SOBA = this;
    sb = SOBA.new_server();
    SOBA.serve(sb);
    app = SOBA.get_app(sb);
    router = SOBA.get_router(sb);
    router.on('helo', function(socket, P, next) {
      debug('©Gp1qF', P);
      return next();
    });
  }

}).call(this);
