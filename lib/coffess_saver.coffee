#<script type="text/coffeescript" target="jch_saver.js">
fs = require 'fs'
MD5 = require 'MD5'
exec = (require 'child_process').exec

##################################
LOG_INFO = "\u001b[1;37m[ JCH ]\u001b[0m\t"
##################################

pub =

  _genContent: (id, origin, strToAdd)->
    # use this to replace the origin file with new component
    regStr = "\\/\\*_JCH_#{id.replace('/', '\\/')}[\\w\\W]*?\\/\\*_JCH_\\*\\/[\\n]?"

    find = false
    #console.log "#{LOG_INFO}handled code block  >>>  #{id}"

    res =  origin.replace(new RegExp(regStr, 'g'), (match, p1)->
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
    # save result s to the file
    fs.writeFileSync(fp, s)

  target: {}


  # css javascript related
  insert: (strToAdd, opts)->
    console.log "#{LOG_INFO}[Insert] #{opts.target}"
    try
    # file exist, update first
      origin = fs.readFileSync(opts.target, {encoding: 'utf8'})
      res = @_genContent(opts.id, origin, strToAdd)


      if res
        @_write(opts.target, res)
      else
        @_append(opts.target, strToAdd)

    catch err
    # file doesn't exist, write passed content to the new file
      @_write(opts.target, strToAdd)


  # html, smarty related
  save: (target, content)->
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
        console.error "#{LOG_INFO}[HTML][S] #{target}"
        fs.writeFileSync(target, content)
    else
      # new file, check if there is any data to write
      if content isnt ""
        # write and then add to svn system
        fs.writeFileSync target, content
        console.log "#{LOG_INFO}[HTML][C] #{target}"
        #exec "svn add #{target}", (err)->
        # console.error "#{LOG_INFO}[Create HTML] #{err}" if err

module.exports = pub

#</script>