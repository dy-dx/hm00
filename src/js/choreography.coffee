eases = require 'eases'
shaders = require './shaders'
particles = require './particles'

timeline = [
  name: 'intro_0_fade'
  beginTime: 0
,
  name: 'intro_1'
  beginTime: 11.5
,
  name: 'verse_1_rotate'
  beginTime: 29.89
]
for sceneInfo, idx in timeline
  sceneInfo.endTime = timeline[idx+1]?.beginTime || 50
  sceneInfo.duration = sceneInfo.endTime - sceneInfo.beginTime

scenes =
  default:
    init: ->
      @model.object.position.z = 0
      @camera.position.y = @model.center().y+10
    update: (s, time) ->
      c = s.audio.level * 3
      particles.material.color.setRGB(c, c, c)
      s.hm.model.dressMaterial.uniforms.time.value = time

  intro_0_fade:
    init: ->
      @model.setShader shaders.stripes
      @uniforms = @model.dressMaterial.uniforms
      @uniforms.brightness.value = 0
      @model.object.position.z = -60
      @camera.position.x = -5
      @camera.position.z = 70
      @camera.position.y = @model.center().y+10
    update: (time) ->
      # Linear from z = -90 to z = -45
      @model.object.position.z = -90 + 45 * time / @sceneInfo.duration
      @camera.lookAt @model.center()
      # fade particle brightness from 0 to 1
      fadeDuration = 5
      particles.material.color.multiplyScalar(Math.min(time / fadeDuration, 1))

  intro_1:
    init: ->
      @model.setShader shaders.stripes
      @uniforms = @model.dressMaterial.uniforms
      @uniforms.brightness.value = 1
      @model.object.position.z = -45
      @camera.position.x = -5
      @camera.position.z = 70
      @camera.position.y = @model.center().y+10
    update: (time) ->
      # Linear from z = -45 to z = 0
      @model.object.position.z = -45 * (1 - time / @sceneInfo.duration)
      @camera.lookAt @model.center()

      # snare taps
      if time < 2.5
        @uniforms.balance.value = Math.max(0, time*(@audio.level - 0.15)) * eases.cubicInOut(time/4)
      else
        @uniforms.balance.value = eases.cubicInOut(Math.min(1, time/7)) * 0.9

  verse_1_rotate:
    init: ->
      @model.setShader shaders.turbulence
      @uniforms = @model.dressMaterial.uniforms
    update: (time) ->
      @camera.position.x = 70 * Math.sin(time)
      @camera.position.z = 70 * Math.cos(time)
      @camera.lookAt @model.center()


module.exports = class Choreography
  constructor: (@audio, @hm) ->
    @time = 0
    # Code smell here obviously
    @sceneGraph = @hm.scene
    @camera = @hm.camera
    @lights = @hm.lights


  update: (time) ->
    @time = time

    if !@scene || @scene.sceneInfo.endTime <= @time || @time < @scene.sceneInfo.beginTime
      @scene = @startScene(@findNextScene())
    return unless @scene

    scenes.default.update(@, @time - @scene.sceneInfo.beginTime)
    @scene.update(@time - @scene.sceneInfo.beginTime)


  findNextScene: ->
    for sceneInfo in timeline
      if sceneInfo.endTime > @time >= sceneInfo.beginTime
        return sceneInfo
    # Just loop current scene if next can't be found
    fakeSceneInfo =
      name: @scene.sceneInfo.name
      duration: @scene.sceneInfo.duration
      beginTime: @time
      endTime: @scene.sceneInfo.endTime + @scene.sceneInfo.duration
    timeline.push fakeSceneInfo
    return fakeSceneInfo

  startScene: (sceneInfo) ->
    # TODO: destroy previous scene
    scene = scenes[sceneInfo.name]
    scene.sceneInfo = sceneInfo
    scene.camera = @camera
    scene.sceneGraph = @sceneGraph
    scene.audio = @audio
    scene.model = @hm.model
    scenes.default.init.call(scene, @)
    scene.init(@)
    console.log 'starting', sceneInfo.name, 'at', @time
    scene



