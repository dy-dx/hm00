THREE = require 'three'
GUI = require('dat-gui').GUI
audio = require './audio'
Choreography = require './choreography'
shaders = require './shaders'
particles = require './particles'

class Ham
  constructor: ->
    @time = 0
    @timeScale = 1
    @autoRotate = 0

    @setupScene()
    @setupGUI()
    @choreography = new Choreography(audio, @)

  setupGUI: ->
    @gui = new GUI()
    # @gui.add @, 'timeScale', 0, 5
    @gui.add @, 'autoRotate', 0, 2

  setupScene: ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 70, 1, 10, 200
    @scene.add @camera

    @lights = [
      new THREE.PointLight 0xFFFFFF, 0.3
      new THREE.PointLight 0xFFFFFF, 0.3
      new THREE.PointLight 0xFFFFFF, 0.0
      new THREE.PointLight 0xFFFFFF, 0.0
    ]
    @lights[0].position.set  80, 80, -10
    @lights[1].position.set -80, 80,  10
    @lights[2].position.set  80, 70,  80
    @lights[3].position.set -80, 70, -80

    @scene.add light for light in @lights
    @scene.add particles

  setupRenderer: (@runner, @canvas) ->
    @renderer = new THREE.WebGLRenderer(canvas: @canvas, antialias: false)
    @renderer.setClearColor(0x0, 1)

  loadModel: (geom, mats) ->
    @model = new Model(geom, mats)
    @scene.add @model.object


  tick: (dt) ->
    @dt = Math.max(audio.currentTime() - @time, 0)
    @time = audio.currentTime()
    audio.updateAudio()
    @model.updateAnimation(@dt, @time)
    @choreography.update(@time)
    # fixme
    c = audio.level * 3
    particles.material.color.setRGB(c, c, c)

  render: ->
    @renderer.render @scene, @camera


class Model
  constructor: (geom, mats) ->
    @dressMaterial = new THREE.ShaderMaterial shaders.default
    for mat, idx in mats
      if mat.name == 'DRESS.001'
        mats[idx] = @dressMaterial
        mat = mats[idx]
      mat.morphTargets = true

    @object = new THREE.Mesh geom, new THREE.MeshFaceMaterial mats
    @object.scale.multiplyScalar(50)
    @object.position.y = -50

    @setupAnimation()

  center: ->
    new THREE.Vector3().addVectors(
      @object.position,
      new THREE.Vector3(0, 50, 0)
    )

  setupAnimation: ->
    @animation = new THREE.MorphAnimation(@object)
    # animate at 100 bpm, 2 beats per animation duration
    # (even though the song is 64bpm)
    @animation.duration = (1000*60 / 128) * 2
    # I don't know why but this keeps it from blowing up
    @animation.frames -= 0.00000001
    @animation.play()

  updateAnimation: (dt, time) ->
    @dressMaterial.uniforms.time?.value += dt
    @animation.update(dt * 1000)

module.exports = new Ham()
