_    = require "lodash"
path = require "path"
fs   = require "fs"
walk = require "walk"

###
  Used to find a list of files within a basePath.

  Call getResourceList({String} directoryWithFiles, {Function(files)} callback).
###
class ResourceLocator
  
  basePath: "data"

  frameworkIgnored: [ "manifest.json" ]
  
  constructor: (conf) ->
    _.extend @, conf
    @fullBasePath = path.resolve @basePath

  ###
    Get a list of all resources within the given directory.
    This function will ensure the path is within the configured
    base directory.
  ###
  getResourceList: (dir, callback) =>
    # getSafePath will throw an error if the path is not safe.
    try
      safePath = @_getSafePath dir
      if fs.existsSync(safePath)
        @_getFilesRecursive safePath, (files) ->
          callback null, { list: files, baseDir: safePath }
      else
         callback { msg: "'#{dir}' Not found", type: "ResourceNotFoundException" }
    catch e
      callback { msg: e, type: "SecurityException" }


  ###
    Get all directories from the basePath.
    @param {Function} callback Call me with the dirs.
  ###
  getResourceDirectories: (callback) =>
    fs.readdir @basePath, (err, files) =>
      dirs = []
      files.forEach (file) =>
        fullPath = path.join @basePath, file
        stat = fs.lstatSync fullPath
        if stat.isDirectory()
          dirs.push file
      callback(dirs)


  _getSafePath: (dir) =>
    safePath = path.resolve "#{@fullBasePath}#{path.sep}#{dir}"
    unless 0 is safePath.indexOf @fullBasePath
      throw "Attempted to access path outside of the configuration directory."
    safePath
    
  _getFilesRecursive: (dir, callback) =>
    baseDir = path.resolve dir
    files = []
    walker = walk.walk baseDir, { followLinks: false }
    walker.on "file", (root, stat, next) =>
      unless @_isFrameworkIgnored(stat.name)
        files.push path.resolve("#{root}#{path.sep}#{stat.name}")
      next()
    walker.on "end", -> callback files

  _isFrameworkIgnored: (file) =>
    _.contains @frameworkIgnored, file
    
module.exports = ResourceLocator