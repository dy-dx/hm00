`var glslify = require('glslify');`
# glslify = require('glslify')

THREE = require('three')
xtend = require('xtend')

# inline our shader code
source = glslify
  vertex: './pass.vert'
  fragment: './fancy.frag'
  sourceOnly: true

# converts to ThreeJS shader object:
# { vertexShader, fragmentShader, uniforms, attributes }
createShader = require('three-glslify')(THREE)

module.exports = (opts) ->
  xtend(createShader(source), opts)
