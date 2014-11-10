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
      @hm.model.object.position.z = -50
      @camera.position.x = 0
      @camera.position.z = 90
      @camera.position.y = @hm.model.center().y
    update: (time) ->
      @hm.model.object.position.z = -50 + 50 * time / @sceneInfo.duration
      @camera.lookAt @hm.model.center()

  verse1rotate:
    init: ->
      @hm.model.object.position.z = 0
      @camera.position.y = @hm.model.center().y
    update: (time) ->
      @camera.position.x = 90 * Math.sin(time)
      @camera.position.z = 90 * Math.cos(time)
      @camera.lookAt @hm.model.center()


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
    scene.hm = @hm
    scene.init(@)
    console.log 'starting', sceneInfo.name, 'at', @time
    scene



