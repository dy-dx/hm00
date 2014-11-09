shaderCreators =
  curl       : require '../shaders/curl'
  turbulence : require '../shaders/turbulence'
  checker    : require '../shaders/checker'


setupShader = (shaderCreator) ->
  shader = shaderCreator
    lights: false
    wireframe: false

  if shader.lights
    shader.uniforms = THREE.UniformsUtils.merge([THREE.UniformsLib['lights'], shader.uniforms])
  return shader


shaders = {}

for k, v of shaderCreators
  shaders[k] = setupShader(v)

shaders.default = shaders.checker


module.exports = shaders
