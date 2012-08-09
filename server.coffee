# first node server written purely in coffeescript
# now Im understanding that coffescript compiler is nothing more than a node server 
# with coffeescript interpreter built on top!

# require http module ( part of node )
http = require('http')
url = require('url')

# make a class that handles this shit

class Application

	constructor: (@req, @res) ->
		@pathInfo = url.parse(@req.url,true)

	process: ->
		if /^\/javascripts\//.test @pathInfo.pathname
			new JavaScriptProcessor(@req, @res, @pathInfo).process()
		else
			new PublicProcessor(@req, @res, @pathInfo).process()

class Processor

	constructor: (@req, @res, @pathInfo) ->

	contentType: ->
		throw new Error("contentType must be implemented!")

	process: ->
		throw new Error("process must be implemented!")

	pathName: ->

	write: (data, status = 200, headers ={}) ->


class JavaScriptProcessor extends Processor

	contentType: ->

	process: ->



# set simple variables for port and IP address for the server to sit on

port = 3000
ip = "127.0.0.1"

# now instantiate a server by calling the function of the http module and assign it to a variable called 'server'
# http.createServer (req,res) = create server takes in arguments for req ( request ) and res ( response )
# response is a CALLBACK function pointer 

server = http.createServer (req,res) ->
	app = new Application(req, res) ->
	app.process()

server.listen(port,ip)

console.log "Server running at http://#{ip}:#{port}/"

