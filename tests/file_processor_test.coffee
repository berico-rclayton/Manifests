HandlebarsProcessor = require "../services/processors/handlebarsProcessor.coffee"

conf = 
  processors:
    "handlebars": HandlebarsProcessor

rl = new (require "../services/resourceLocator.coffee")()
fp = new (require "../services/fileProcessor.coffee")(conf)

baseDirectory = "./tests/testTest/"

rl.getFilesRecursive baseDirectory, (files) ->
  console.log "Done!"
  fp.processFiles baseDirectory, files, { name: "Richard" }, (zip) ->
    console.log zip