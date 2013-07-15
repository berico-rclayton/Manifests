_    = require "lodash"
fs   = require "fs"
path = require "path"

###
  Loads context from an external file.
###
class ContextLoader

  contextFilename: "manifest.json"

  constructor: (conf) ->
    _.extend @, conf if conf?

  ###
    Load context from a directory.
  ###
  fromDirectory: (dir, callback) ->
    fullPath = path.join dir, @contextFilename
    fs.readFile fullPath, { encoding: "utf8" }, (err, file) ->
      unless err?
        try
          jsObject = JSON.parse file
          callback null, jsObject
        catch e
          callback { msg: e, type: "JsonParseException" }
      else
        callback { msg: err, type: "FileSystemException" }


module.exports = ContextLoader