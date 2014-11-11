shaderCreators =
  curl       : require '../shaders/curl'
  turbulence : require '../shaders/turbulence'
  checker    : require '../shaders/checker'
  stripes    : require '../shaders/stripes'


setupShader = (shaderCreator) ->
  shader = shaderCreator
    lights: false
    wireframe: false
    morphTargets: true

  if shader.lights
    shader.uniforms = THREE.UniformsUtils.merge([THREE.UniformsLib['lights'], shader.uniforms])
  return shader


shaders = {}

for k, v of shaderCreators
  shaders[k] = setupShader(v)

shaders.default = shaders.checker


module.exports = shaders
