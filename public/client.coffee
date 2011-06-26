
sessionId = null
apiKey = null
token = null
session = null

addHandler = (session,type,callback) ->
	console.log "addHandler"
	session.addEventListener type, callback
	
subscribeToStreams = (streams) ->
	streamProps = width: 100, height: 100, subscribeToAudio: false
	for stream in streams
		session.subscribe stream, "opponent", streamProps if stream.connection.connectionId != session.connection.connectionId 
		

setupSession = (session) ->
	console.log "setupSession #{session}"
	addHandler session, "sessionConnected", (event) -> 
		console.log "sessionConnected"
		subscribeToStreams event.streams
		publishProps = width: 100, height: 100, subscribeToAudio: false
		session.publish("me",publishProps)
		
	addHandler session, "streamCreated", (event) -> 
		console.log "streamCreated"
		subscribeToStreams event.streams
	

connectOpenTok = () ->
	console.log  "connectOpenTok sessionId=#{sessionId}"
	session = TB.initSession(sessionId)
	TB.setLogLevel(4)
	setupSession session
	
	console.log "apiKey = #{apiKey} token = #{token}"
	session.connect(apiKey,token)

# creating player divs
$(document).ready () ->
	$("#playingField").append "<div id='opponent' class='opponent' />"
	$("#playingField").append "<div class='me'><div id='me'></div></div>"  	
	
client = new Faye.Client "http://localhost:3000/faye"
client.subscribe "/yourface", (message) ->
	console.log "faye message -> #{JSON.stringify message}"
	sessionId = message.sessionId
	apiKey = message.apiKey
	token = message.token
	connectOpenTok()

