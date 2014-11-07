`var glslify = require('glslify');`
# glslify = require('glslify')

THREE = require('three')
xtend = require('xtend')

source = glslify
  vertex: './pass.vert'
  fragment: './checker.frag'
  sourceOnly: true

createShader = require('three-glslify')(THREE)

module.exports = (opts) ->
  xtend(createShader(source), opts)
