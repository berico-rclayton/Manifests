rl = new (require "../services/resourceLocator.coffee")()
rl.getFilesRecursive "../", (files) ->
  console.log "Done!"
  console.log files