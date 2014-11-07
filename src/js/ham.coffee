THREE = require 'three'
GUI = require('dat-gui').GUI
audio = require './audio'
shaderCreators =
  curl       : require '../shaders/curl'
  turbulence : require '../shaders/turbulence'
  checker    : require '../shaders/checker'


class Ham
  constructor: ->
    @time = 0
    @timeScale = 1
    @autoRotate = 0

    @setupScene()
    @setupGUI()
    @sequencer = new HamSequencer()

  setupGUI: ->
    @gui = new GUI()
    @gui.add @, 'timeScale', 0, 5
    @gui.add @, 'autoRotate', 0, 2

  setupScene: ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 70, 1, 1, 2000
    @scene.add @camera

    @lights = [
      new THREE.PointLight 0xFFFFFF, 0.3
      new THREE.PointLight 0xFFFFFF, 0.3
      new THREE.PointLight 0xFFFFFF, 0.0
      new THREE.PointLight 0xFFFFFF, 0.0
    ]
    @lights[0].position.set  800, 800, -100
    @lights[1].position.set -800, 800,  100
    @lights[2].position.set  800, 700,  800
    @lights[3].position.set -800, 700, -800

    @scene.add light for light in @lights

  setupRenderer: (@runner, @canvas) ->
    @renderer = new THREE.WebGLRenderer(canvas: @canvas, antialias: false)
    @renderer.setClearColor(0x0, 1)

  loadModel: (geom, mats) ->
    @model = new Model(geom, mats, @sequencer)
    @scene.add @model.object


  tick: (dt) ->
    # @dt = dt*0.001*@timeScale
    @dt = audio.context.currentTime - @time
    @time += @dt
    @model.updateAnimation(@dt, @time)

  render: ->
    @camera.position.x = 900*Math.sin(@time * @autoRotate)
    @camera.position.z = 900*Math.cos(@time * @autoRotate)
    @camera.position.y = 200
    @camera.lookAt @scene.position
    @renderer.render @scene, @camera


class Model
  constructor: (geom, mats, @sequencer) ->
    @dressMaterial = new THREE.ShaderMaterial @sequencer.defaultShader()
    for mat, idx in mats
      if mat.name == 'DRESS.001'
        mats[idx] = @dressMaterial
        mat = mats[idx]
      mat.morphTargets = true

    @object = new THREE.Mesh geom, new THREE.MeshFaceMaterial mats
    @object.scale.multiplyScalar(500)
    @object.position.y = -500

    @setupAnimation()

  setupAnimation: ->
    @animation = new THREE.MorphAnimation(@object)
    # 100 bpm, 2 beats per animation duration
    @animation.duration = (1000*60 / 100) * 2
    # I don't know why but this keeps it from blowing up
    @animation.frames -= 0.00000001
    @animation.play()

  updateAnimation: (dt, time) ->
    @dressMaterial.uniforms.time?.value += dt
    @animation.update(dt * 1000)


class HamSequencer
  constructor: ->
    @shaders = {}
    for k, v of shaderCreators
      @shaders[k] = @createShader(v)

  # ??? What am I doing?
  createShader: (shaderCreator) ->
    shader = shaderCreator
      lights: false
      wireframe: false

    if shader.lights
      shader.uniforms = THREE.UniformsUtils.merge([THREE.UniformsLib['lights'], shader.uniforms])
    return shader

  defaultShader: ->
    @shaders.checker


module.exports = Ham
