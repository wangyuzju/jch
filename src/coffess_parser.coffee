#<script type="text/coffeescript" target="../lib/jch_parser.js">
fs = require 'fs'
path = require 'path'
exec = (require 'child_process').exec
MD5 = require 'MD5'
jchSaver = require './coffess_saver'

##################################
LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t"
DEBUG = false
##################################

tools =
    getAttribute: (domString) ->
        ret = {}
        # convert "a, b" to "a,b" form
        domString = domString.replace(/,\s*/g, ",")

        # match " target =  'hello_world.js' "
        regDOMAttr = /([\w]*)[\s]*=[\s]*([\w\/._,]*)/g

        domString.replace(regDOMAttr, (match, p1, p2)->
            ret[p1] = p2
        )
        return ret

class Coffess
    constructor: (fp)->
        @_index_js = 0
        @_index_css = 0
        @_fp = fp
        @_prjFp = @_fp.replace(/[\W\w]*src\//, '')
        @_fc = fs.readFileSync fp, {encoding: 'utf8'}

        if @_fc[0...@_fc.indexOf('\n')] isnt '{*remove*}'
            @_moduleInUse = true

    # used to genetare css/js source code and insert them to target file
    _saveTo: (source, target)->
        console.log target + 'Saved'
        console.log source

    _wrapJchInfo: (source, type, indexHash)->
        @_id = "#{@_prjFp}_#{type}_#{indexHash}"

        return "/*_JCH_#{@_id} */\n#{source}/*#{""}_JCH_*/\n"


    _resolveCSS: (match, arrP..., offset, origin)->
        config = tools.getAttribute arrP[0].trim().replace(/['"]/g, "")
        source = arrP[1];

        if config.target
            for target in config.target.split(',')
                @_target = path.resolve(path.dirname(@_fp), target)
                @_genCSS(source, target, config.type, @_index_css++)

            # return empty string to remove css from jch file
            return ""
        else
            # keep inline style tag
        return match

    _genCSS: (source, target, type, indexHash)->
        if !@_moduleInUse
            console.error "#{LOG_INFO}delete CSS from #{target}"
            return

        target = path.resolve(path.dirname(@_fp), target)
        switch type
            when "text/less"
                self = @
                tempFile = "/tmp/jch_css_#{MD5 target+type+indexHash}"
                fs.writeFileSync tempFile, source
                exec("lessc #{tempFile}", (err, stdout, stderr)->
                    fs.unlink tempFile, ()->
                    if err
                        console.error err
                        return
                    if DEBUG
                        # 显示编译结果
                        console.info stdout
                    # 保存到目标文件
                    jchSaver.insert self._wrapJchInfo(stdout, type, indexHash),
                        target: target
                        id: self._id
                        fileName: self._fp
                )
            else
                jchSaver.insert @_wrapJchInfo(source, type, indexHash),
                    target: target
                    from: @_fp
                    id: @_id

    _resolveJS: (match, arrP..., offset, origin)->
        config = tools.getAttribute arrP[0].trim().replace(/['"]/g, "")
        source = arrP[1];

        # tag has target attribute, which is need to be merged into targetfile
        # otherwise is normal inline statement, keep that
        if config.target
            for target in config.target.split(',')
                @_target = path.resolve(path.dirname(@_fp), target)
                @_genJS(source, target, config.type, @_index_js++)

            return ""
        else
            # keep inline script tag
            return match




    _genJS: (source, target, type, indexHash)->
        # remove
        if !@_moduleInUse
            console.error "delete!"
            return

        target = path.resolve(path.dirname(@_fp), target)
        # add
        switch type
            when 'text/coffeescript' # then return
                self = @
                tempFile = "/tmp/jch_js_#{MD5 target+type+indexHash}"
                fs.writeFileSync tempFile, source
                exec("coffee -bcp #{tempFile}", (err, stdout, stderr)->
                    fs.unlink tempFile, ()->
                    if err
                        console.log err
                        return
                    if DEBUG
                        console.log "#{LOG_INFO} Coffee From \"#{self._fp}\""
                        console.info stdout
                    # 插入到目标文件
                    jchSaver.insert self._wrapJchInfo(stdout, type, indexHash),
                        target: target
                        id: self._id
                        fileName: self._fp
                )
            else
                jchSaver.insert @_wrapJchInfo(source, type, indexHash),
                    target: target
                    from: @_fp
                    id: @_id


    # source is now javascript file
    #@_saveTo source, target

    _genTmpl: ()->


        #split jch file into different type and call matched handle
    handle: ()->
        # remove comment
        @_fc = @_fc.replace /<!--[\w\W]*?-->/g, ""

        # hadle CSS related
        regCSS = /<style([^>]*)>([\w\W]*?)<\/style>/g
        @_fc = @_fc.replace(regCSS, @_resolveCSS.bind(@))

        # handle JS related
        regJS = /<script([^>]*)>([\w\W]*?)<\/script>/g
        # need to bind replace handle function's target
        @_fc = @_fc.replace(regJS, @_resolveJS.bind(@))

        # handle tmpl related if it's not empty
        @_fc = @_fc.trim()

        if (@_fc.replace /#/g, "").trim() is "" then @_fc = ""

        #console.info "#{LOG_INFO}[Start Parse] JCH File \"#{@_fp}\""
        jchSaver.save @_fp, path.resolve(path.dirname(@_fp), "../#{(path.basename @_fp)[8...]}"), @_fc


pub =
    parse: (fp, debug)->
        parser = new Coffess(fp)
        parser.debug = debug
        console.log "\u001b[37m--- Coffess\<#{fp}\> ---\u001b[0m\t"
        parser.handle()

module.exports = pub
#</script>