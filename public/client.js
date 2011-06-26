(function() {
  var addHandler, apiKey, client, connectOpenTok, session, sessionId, setupSession, subscribeToStreams, token;
  sessionId = null;
  apiKey = null;
  token = null;
  session = null;
  addHandler = function(session, type, callback) {
    console.log("addHandler");
    return session.addEventListener(type, callback);
  };
  subscribeToStreams = function(streams) {
    var stream, streamProps, _i, _len, _results;
    streamProps = {
      width: 100,
      height: 100,
      subscribeToAudio: false
    };
    _results = [];
    for (_i = 0, _len = streams.length; _i < _len; _i++) {
      stream = streams[_i];
      _results.push(stream.connection.connectionId !== session.connection.connectionId ? session.subscribe(stream, "opponent", streamProps) : void 0);
    }
    return _results;
  };
  setupSession = function(session) {
    console.log("setupSession " + session);
    addHandler(session, "sessionConnected", function(event) {
      var publishProps;
      console.log("sessionConnected");
      subscribeToStreams(event.streams);
      publishProps = {
        width: 100,
        height: 100,
        subscribeToAudio: false
      };
      return session.publish("me", publishProps);
    });
    return addHandler(session, "streamCreated", function(event) {
      console.log("streamCreated");
      return subscribeToStreams(event.streams);
    });
  };
  connectOpenTok = function() {
    console.log("connectOpenTok sessionId=" + sessionId);
    session = TB.initSession(sessionId);
    TB.setLogLevel(4);
    setupSession(session);
    console.log("apiKey = " + apiKey + " token = " + token);
    return session.connect(apiKey, token);
  };
  $(document).ready(function() {
    $("#playingField").append("<div class='opponent'><div id='opponent'></div></div>");
    $("#playingField").append("<div class='me'><div id='me'></div></div>");
    return $('body').keydown(function(event) {
      var curLeftPos, curTopPos, offset;
      curLeftPos = $(".me").offset().left;
      curTopPos = $(".me").offset().left;
      offset = 50;
      if (event.keyCode === 37) {
        $(".me").offset({
          left: Math.max(13, curLeftPos - offset)
        });
      }
      if (event.keyCode === 39) {
        return $(".me").offset({
          left: Math.min(600, curLeftPos + offset)
        });
      }
    });
  });
  client = new Faye.Client("http://192.168.50.152:3000/faye");
  client.subscribe("/yourface", function(message) {
    console.log("faye message -> " + (JSON.stringify(message)));
    sessionId = message.sessionId;
    apiKey = message.apiKey;
    token = message.token;
    return connectOpenTok();
  });
}).call(this);
