fs = require 'fs'
path = require 'path'
exec = (require 'child_process').exec
MD5 = require 'MD5'
jchSaver = require './jch_saver'

##################################
LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t"
##################################

tools =
  getAttribute: (domString) ->
    ret = {}
    # match " target =  'hello_world.js' "
    regDOMAttr = /([\w]*)[\s]*=[\s]*([\w\/._]*)/g

    domString.replace(regDOMAttr, (match, p1, p2)->
      ret[p1] = p2
    )
    return ret


pub =
# file path
  _fp: null
# file path relative with project
  _prjFp: null
# file contents
  _fc: null

# a flag determine to add / remove component form target file
  _moduleInUse: false


  _load: (fp)->
    @_fp = fp
    @_prjFp = @_fp.replace(/[\W\w]*src\//, '')
    @_fc = fs.readFileSync(fp, {encoding: 'utf8'})

    if @_fc[0...@_fc.indexOf('\n')] isnt '{*remove*}'
      @_moduleInUse = true

  #used to genetare css/js source code and insert them to target file

  _saveTo: (source, target)->
    console.log target + 'Saved'
    console.log source

  _wrapJchInfo: (source, type) ->
    @_id = "#{@_prjFp}_#{type}"


    return "/*_JCH_#{@_id} */\n#{source}/*_JCH_*/\n"



  _resolveCSS: (match, arrP..., offset, origin)->
    config = tools.getAttribute arrP[0].trim().replace(/['"]/g, "")
    source = arrP[1];

    if config.target
      pub._target = path.resolve(path.dirname(pub._fp), config.target)
      pub._genCSS(source, config.target, config.type)

    # return empty string to remove css from jch file
    return ""

  _genCSS: (source, target, type)->
    if !@_moduleInUse
      console.error "#{LOG_INFO}delete CSS from #{target}"
      return

    target = path.resolve(path.dirname(pub._fp), target)
    switch type
      when "text/less"
        self = @
        tempFile = "/tmp/jch_#{MD5 source}"
        fs.writeFileSync tempFile, source
        exec("lessc #{tempFile}", (err, stdout, stderr)->
          fs.unlink tempFile
          if err
            console.error err
            return
          console.info stdout
          jchSaver.insert self._wrapJchInfo(stdout, type),
            target: target
            id: self._id
        )
      else
        jchSaver.insert @_wrapJchInfo(source, type),
          target: @_target
          from: @_fp
          id: @_id

  _resolveJS: (match, arrP..., offset, origin)->
    config = tools.getAttribute arrP[0].trim().replace(/['"]/g, "")
    source = arrP[1];

    # tag has target attribute, which is need to be merged into targetfile
    # otherwise is normal inline statement, keep that
    if config.target
      pub._target = path.resolve(path.dirname(pub._fp), config.target)
      pub._genJS(source, config.target, config.type)

    return ""


  _genJS: (source, target, type)->
    # remove
    if !@_moduleInUse
      console.error "delete!"
      return

    target = path.resolve(path.dirname(pub._fp), target)
    # add
    switch type
      when 'text/coffeescript'# then return
        self = @
        tempFile = "/tmp/jch_js_#{MD5 source}"
        fs.writeFileSync tempFile, source
        exec("coffee -bcp #{tempFile}", (err, stdout, stderr)->
          fs.unlink tempFile
          if err
            console.log err
            return
          console.log "#{LOG_INFO} Coffee From \"#{self._fp}\""
          console.info stdout
          jchSaver.insert self._wrapJchInfo(stdout, type),
            target: self._target
            id: self._id
        )
      else
        jchSaver.insert self._wrapJchInfo(source, type),
          target: target
          from: @_fp
          id: @_id


# source is now javascript file
#@_saveTo source, target

  _genTmpl: ()->



    #split jch file into different type and call matched handle
  _prepare: ()->
    # remove comment
    @_fc = @_fc.replace /<!--[\w\W]*?-->/g, ""

    # hadle CSS related
    regCSS = /<style([^>]*)>([\w\W]*?)<\/style>/g
    @_fc = @_fc.replace(regCSS, @_resolveCSS)

    # handle JS related
    regJS = /<script([^>]*)>([\w\W]*?)<\/script>/g
    @_fc = @_fc.replace(regJS, @_resolveJS)


    # handle tmpl related if it's not empty
    @_fc = @_fc.trim()

    if (@_fc.replace /#/g, "").trim() is "" then @_fc = ""

    console.info "#{LOG_INFO}Start Parse JCH File \"#{@_fp}\"\n"
    jchSaver.save path.resolve(path.dirname(@_fp), "../#{(path.basename @_fp)[4...]}"), @_fc


  parse: (fp, debug)->
    @debug = debug
    @_load(fp)

    @_prepare()



module.exports = pub