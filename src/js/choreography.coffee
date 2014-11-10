shaders = require './shaders'

timeline = [
  name: 'intro'
  beginTime: 0
,
  name: 'verse1rotate'
  beginTime: 29.89
]
for sceneInfo, idx in timeline
  sceneInfo.endTime = timeline[idx+1]?.beginTime || 40
  sceneInfo.duration = sceneInfo.endTime - sceneInfo.beginTime

scenes =
  intro:
    init: ->
      @model.setShader shaders.default
      @model.object.position.z = -160
      @camera.position.x = -5
      @camera.position.z = 80
      @camera.position.y = @model.center().y+10
    update: (time) ->
      # Linear from z = -160 to z = 0
      @model.object.position.z = -160 * (1 - time / @sceneInfo.duration)
      @camera.lookAt @model.center()

  verse1rotate:
    init: ->
      @model.setShader shaders.turbulence
      @model.object.position.z = 0
      @camera.position.y = @model.center().y+10
    update: (time) ->
      @camera.position.x = 80 * Math.sin(time)
      @camera.position.z = 80 * Math.cos(time)
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
    scene.init(@)
    console.log 'starting', sceneInfo.name, 'at', @time
    scene



