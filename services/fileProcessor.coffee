_     = require "lodash"
fs    = require "fs"
path  = require "path"
mkdir = require "mkdirp"
targz = require "tar.gz"

###
  Used to process a list of files, delegating some processing to supplied processors
  (by extension), zipping the contents and returning the path to the zipped content
  back to those who care.
###
class FileProcessor
  
  tmpBasePath: "tmp"
  zipBasePath: "tmp/zipped/"
  
  processors: {}
  
  constructor: (conf) ->
    _.extend @, conf

  ###
    Given a base directory, a file list, some context, and a callback,
    process the file list, applying the context when necessary.  Zip the
    contents of that directory, and return the path to the Zip via the
    supplied callback.
    @param {String} baseDir - Base Directory of the file list.
    @param {Array} of {String} files - an Array of file paths to be processed.
    @param {Object} context - the object with properties you want to use to
       configure the processor that will be handling the file.
    @param {Function} callback - the function you want called when the process
      is done.  Signature: {String} zipFile
  ###
  processFiles: (baseDir, files, context, callback) ->
    fullBaseDir = path.resolve baseDir
    try
      tmpPath = @_generateTempDirectory()
    catch e
      return callback { msg: e, type: "FileSystemException" }
    moveToTempSpace = []
    for file in files
      ext = @_getExtension(file)
      if @processors[ext]?
        try
          processed = @processors[ext](file, context)
          if processed?
            newPath = @_createNewPathInTempDir fullBaseDir, processed.modPathName, tmpPath
            @_streamToTempPath newPath, processed.stream
        catch e
          callback { msg: e, type: "ProcessorException" }
      else
        try
          newPath = @_createNewPathInTempDir fullBaseDir, file, tmpPath
          @_streamToTempPath newPath, fs.createReadStream(file)
        catch e
          callback { msg: e, type: "FileSystemException" }
    @_compressDirectory tmpPath, callback

  ###
    Add a processor to the FileProcessor
    @param extension {Array or String} the extensions' abbreviation (txt, png, etc.)
    @param processor {Function} a function that:
          accepts: {String} pathToFile, {Object} context
          returns: {Object} with properties:
                      {String} modPathName: name (and path) to be written to the temp directory.
                      {Stream} stream: a Node.js Stream with the contents
                   {Null}: indicating this file should be ignored.
  ###
  addProcessor: (extensions, processor) ->
    unless extensions.push?
      extensions = [ extensions ]
    for extension in extensions
      @processors[extension] = processor

  _generateTempDirectory: ->
    d = new Date().getTime()
    tmpPath = path.resolve "#{@tmpBasePath}#{path.sep}#{d}#{path.sep}manifest"
    mkdir.sync tmpPath
    tmpPath
  
  _streamToTempPath: (newPath, stream) ->
    stream.pipe(fs.createWriteStream(newPath))
  
  _compressDirectory: (dir, callback) ->
    d = new Date().getTime()
    zipPath = path.normalize "#{@zipBasePath}#{path.sep}#{d}.tar.gz"
    new targz().compress dir, zipPath, (err) ->
      unless err?
        callback null, zipPath
      else
        callback {msg: err, type: "CompressionException" }
  
  _createNewPathInTempDir: (baseDir, file, tmpPath) ->
    pathDifference = @_getPathDifference baseDir, file
    newPath = path.join tmpPath, pathDifference
    newPathDir = path.dirname newPath
    mkdir.sync newPathDir
    newPath
  
  _getExtension: (file) ->
    ext = path.extname(file)
    if _.isEmpty ext then null else ext.substr(1)

  _getPathDifference: (baseDir, file) ->
    file.substr(baseDir.length)

module.exports = FileProcessor