fs         = require "fs"
handlebars = require "handlebars"
Stream     = require "stream"

toStream = (str) ->
  stream = new Stream()
  stream.pipe = (dest) -> dest.write str
  stream

###
  Uses the file as a Handlebars template and applies the
  context to that template.  This implementation will
  change the filename, removing the "handlebars" extension.
###
HandlebarsProcessor = (file, context) ->
  console.log "Processing Handlebars file: #{file}"

  modPathName = file.substr(0, file.lastIndexOf("."))
  
  source = fs.readFileSync file, { encoding: "utf8" }
  
  template = handlebars.compile(source)
  
  results = template(context)
  
  { modPathName: modPathName, stream: toStream(results) }
  
  
module.exports = HandlebarsProcessor