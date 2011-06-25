http = require 'http'
fs = require 'fs'
faye = require 'faye'
opentok = require 'opentok'
yaml = require('yaml')

# ********* Utility Stuff ***********
process.on 'uncaughtException', (err) ->
  console.log "Error: #{err}"
# Handle non-Bayeux requests
server = http.createServer (request, response) ->
  response.writeHead 200, {'Content-Type': 'text/plain'}
  response.write 'Hello, non-Bayeux request'
  response.end
#  Server logging
serverLog = {
  incoming: (message, callback) ->
    logWithTimeStamp "CLIENT SUBSCRIBED Client ID: #{message.clientId}" if (message.channel == '/meta/subscribe')
    logWithTimeStamp "DEVICE MESSAGE ON CHANNEL: #{message.channel}" if message.channel.match(/\/devices\/*/)
    return callback(message)
}
(logMessage) ->
  timestampedMessage = "#{Date} | {logMessage}"
  console.log timestampedMessage
# *************************************  


# Create instance of OpenTok SDK from YAML config
openTokConfig = yaml.eval(fs.readFileSync('opentok.yml').toString('utf-8'))
console.log openTokConfig.apiSecret
ot = new opentok.OpenTokSDK openTokConfig.apiKey, openTokConfig.apiSecret

# creating a video chat session for everyone:
globalSession = null
ot.createSession "localhost", {}, (session) ->
  globalSession = session

bayeux = new faye.NodeAdapter( mount: '/faye', timeout: 45)


registerPlayer = {
  incoming: (message, callback) ->
    userToken = ot.generateToken({sessionId:globalSession.sessionId})
    bayeux.getClient().publish '/yourface', {sessionId: globalSession, apiKey: openTokConfig.apiKey, token: userToken }
    return callback message  
}

bayeux.addExtension serverLog
bayeux.addExtension registerPlayer
bayeux.attach server
console.log "Starting Faye server on port 300"
server.listen 3000  