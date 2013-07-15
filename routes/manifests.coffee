_                   = require "lodash"
ResourceLocator     = require "../services/resourceLocator.coffee"

resourceLocator = new ResourceLocator()

FileProcessor       = require "../services/fileProcessor.coffee"
handlebarsProcessor = require "../services/processors/handlebarsProcessor.coffee"
ignoreProcessor     = require "../services/processors/ignoreProcessor.coffee"

fileProcessor = new FileProcessor()
fileProcessor.addProcessor ["hb", "handlebars"], handlebarsProcessor
fileProcessor.addProcessor "ignore", ignoreProcessor

ContextLoader       = require "../services/contextLoader.coffee"

contextLoader = new ContextLoader()

handleError = (res, err) ->
  jsonError = JSON.stringify err
  console.log "#{err.type} :: #{jsonError}"
  [code, msg] = switch err.type
    when "SecurityException" then [ 403, "Request violated security conventions of the system." ]
    when "ResourceNotFoundException" then [ 404, "Requested resource not found."]
    when "JsonParseException" then [ 500, "Manifest format was not valid JSON." ]
    when "FileSystemException" then [ 500, "Problem interacting with the resource on the file system." ]
    when "ProcessorException" then [ 500, "Problem encountered processing a file." ]
    when "CompressionException" then [ 500, "Problem encountered compressing manifest." ]
    else [ 500, "There was a problem processing this request." ]
  res.send code, msg

###
  Workflow for retrieving a resource directory, applying the context,
  compressing the result, and sending back to the HTTP response.
###
retrieveResource = (res, resource, context) ->
  mergedContext = context ? {}
  resourceLocator.getResourceList resource, (err, rlist) ->
    unless err?
      contextLoader.fromDirectory rlist.baseDir, (err, implicitContext) ->
        unless err?
          mergedContext = _.extend implicitContext, mergedContext
          fileProcessor.processFiles rlist.baseDir, rlist.list, mergedContext, (err, zipFile) ->
            unless err?
              res.download zipFile, "manifest.tar.gz", (err) ->
                handleError res, err if err?
            else
              handleError res, err
        else
          handleError res, err
    else
      handleError res, err





module.exports = (app) ->

  app.get "/manifests", (req, res) ->
    resourceLocator.getResourceDirectories (dirs) ->
      res.json { resources: dirs }

  app.get "/manifests/:resource", (req, res) ->
    retrieveResource res, req.params.resource, req.query

  app.post "/manifests/:resource", (req, res) ->
    ctx = _.extend req.query, req.body
    retrieveResource res, req.params.resource, ctx

