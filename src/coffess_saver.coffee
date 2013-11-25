#<script type="text/coffeescript" target="../lib/jch_saver.js">
fs = require 'fs'
MD5 = require 'MD5'
exec = (require 'child_process').exec

##################################
LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t"
##################################

stack = {}


cache =
    _findMatchContent: (origin, id)->
        # use this to replace the origin file with new component
        regStr = "\\/\\*_JCH_#{id.replace('/', '\\/')}[\\w\\W]*?\\/\\*_JCH_\\*\\/[\\n]?"
        match = origin.match(new RegExp(regStr))
        if match
            return match[0]
        else
            return false


    _read: (fileName, id)->
        try
            ## console.error("readFile(cache) #{fileName}")
            origin = fs.readFileSync(fileName, {encoding: 'utf8'})
            match = @_findMatchContent(origin, id)
            return match
        catch err
            # console.log (err)
            # file not exist
            return false


    load: (fileName, id, targetFileName)->
        if !stack[fileName]
            stack[fileName] = {}

        return stack[fileName][id] = @._read(targetFileName, id)


    get: (fileName, id, targetFileName)->
        # handle html type in specail way
        if id is 'html'
            stack[fileName] = {} if !stack[fileName]
            return stack[fileName]['html'] if stack[fileName]['html']
            ## console.error ("readFile(html) #{fileName}")
            return stack[fileName]['html'] = fs.readFileSync(targetFileName, {encoding: 'utf8'})

        # handle less and coffee
        if (target = stack[fileName])
            if target[id]
                return target[id]

        return @.load(fileName, id, targetFileName)


    update: (fileName, id, newContent)->
        stack[fileName][id] = newContent


pub =
    _genContent: (id, origin, strToAdd)->
        # use this to replace the origin file with new component
        regStr = "\\/\\*_JCH_#{id.replace('/', '\\/')}[\\w\\W]*?\\/\\*_JCH_\\*\\/[\\n]?"

        find = false
        #console.log "#{LOG_INFO}handled code block  >>>  #{id}"

        res = origin.replace(new RegExp(regStr, 'g'), (match, p1)->
            if not find
                find = true
                #replace matched content to new contene
                return strToAdd
            else
                return ""
        )

        return if find then res else false


    _append: (fp, s)->
        # add new content to the file
        fs.appendFileSync(fp, s)
        return

    _write: (fp, s)->
        ## console.info("Writting!! #{fp}")
        # save result s to the file
        fs.writeFileSync(fp, s)

    target: {}


    # css javascript related
    insert: (strToAdd, opts)->
        oContent = cache.get(opts.fileName, opts.id, opts.target)
        if strToAdd is oContent
            return
        else
            console.log "#{LOG_INFO}[Insert] #{opts.target}"
            try
                # file exist, update first
                ## console.error("readFile #{opts.target}")
                origin = fs.readFileSync(opts.target, {encoding: 'utf8'})
                res = @_genContent(opts.id, origin, strToAdd)

                if res
                    @_write(opts.target, res)
                else
                    @_append(opts.target, strToAdd)

            catch err
                # file doesn't exist, write passed content to the new file
                @_write(opts.target, strToAdd)

            cache.update(opts.fileName, opts.id, strToAdd)


    # html, smarty related
    save: (fileName, target, content)->
        oContent = cache.get(fileName, 'html', target)
        if content is oContent
            return
        else
            if fs.existsSync(target)
                # file exist
                if content is ""
                    # TODO only remove through svn for now
                    #delete origin file
                    exec "rm #{target}", (err, stdout, stderr)->
                        if err
                            console.error "#{LOG_INFO}[HTML][D] #{err}"
                        else
                            console.log "#{LOG_INFO}[HTML][D] #{target}"
                else
                    # update origin file
                    ## console.error "#{LOG_INFO}[HTML][S] #{target}"
                    @._write target, content
            else
                # new file, check if there is any data to write
                if content isnt ""
                    # write and then add to svn system
                    @._write target, content
                    console.log "#{LOG_INFO}[HTML][C] #{target}"

            cache.update(fileName, 'html', content)
    # exec "svn add #{target}", (err)->
    # console.error "#{LOG_INFO}[Create HTML] #{err}" if err

module.exports = pub

#</script>