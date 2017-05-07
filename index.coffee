pug = require 'pug'
html2js = require 'html2js'

# pug 转为js模块的loader
module.exports = (source, other) ->
  # 让loader缓存
  @cacheable()

  try
    # 判断是否包含html标签
    reg = new RegExp '^<([^>\s]+)[^>]*>(.*?<\/\\1>)?$'
    # 如果内容是pug文件
    if not reg.test source
      # 对pug文件进行编译
      html = pug.render source, {}
    # 如果是html，则直接转js
    else
      html = source

    # html2js选项
    options =
      mode: 'compress'
      wrap: false

    # html转为js
    newSource = html2js html, options

    # js字符串转为js模块

    # js模块包装方式
    tmpWrap = @query?.wrap or null
    # 支持CommonJS require导入的方式
    if 'commonjs' is tmpWrap
      newSource = 'var tpl = ' + newSource + ';\n module.exports = tpl;'
    # 支持es6 import导入的方式
    else
      newSource = 'const tpl = `' + newSource + '`;export default tpl;'
  catch e
    @callback e, '', other

  @callback null, newSource, other
  return