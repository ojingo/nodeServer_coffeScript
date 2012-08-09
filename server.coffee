# first node server written purely in coffeescript
# now Im understanding that coffescript compiler is nothing more than a node server 
# with coffeescript interpreter built on top!

# require http module ( part of node )
# requires url module ( also part of node )
http = require('http')
url = require('url')
fs = require('fs')
CoffeScript = require('coffee-script')

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

	pathname: ->
		@pathInfo.pathname

	process: ->
		throw new Error("process must be implemented!")

	write: (data, status = 200, headers ={}) ->
		headers["Content-Type"] ||= @contentType()
		headers["Content-Length"] ||= Buffer.byteLength(data,"utf-8")
		@res.writeHead(status,headers)
		@res.write(data,"utf-8")
		@res.end()


class JavaScriptProcessor extends Processor

	contentType: ->
		"application/x-javascript"

	pathname: ->
		file = (/\/javascripts\/(.+)\.js/.exec(@pathInfo.pathname))[1]
		return #{file}.coffee

	process: ->
		fs.readFile "src/#{@pathname()}", "utf-8", (err,data) =>
			if err?
				@write("",404)
			else
				@write(CoffeeScript.compile(data))



class PublicProcessor extends Processor

	contentType: ->
		ext = (/\.(.+)$/.exec(@pathname()))[1].toLowerCase()
		switch ext
			when "png", "jpg", "jpeg", "gif"
				"image/#{ext}"
			when "css"
				"text/css"
			else
				"text/html"

	pathname: ->
		unless @_pathname
			if@pathinfo.pathname is "/" or @pathinfo.pathname is ""
				@pathinfo.pathname = "index"
			unless /\..+$/.test @pathinfo.pathname
				@pathinfo.pathname += ".html"
			@_pathname = @pathinfo.pathname
		return @_pathname

	process: ->
		fs.readFile "public/#{@pathname()}", "utf-8", (err,data) =>
			if err?
				@write("oops! We can't find the page you are looking for!", 404)
			else
				@write(data)




# set simple variables for port and IP address for the server to sit on

port = 3000
ip = "127.0.0.1"

# now instantiate a server by calling the function of the http module and assign it to a variable called 'server'
# http.createServer (req,res) = create server takes in arguments for req ( request ) and res ( response )
# response is a CALLBACK function pointer 

server = http.createServer (req,res) ->
	app = new Application(req, res)
	app.process()

server.listen(port,ip)

console.log "Server running at http://#{ip}:#{port}/"

