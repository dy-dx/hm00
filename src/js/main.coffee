# $ = require 'jquery'
# _ = require 'lodash'
THREE = require 'three'
Stats = require 'stats-js'
GUI = require('dat-gui').GUI
testbed = require 'canvas-testbed'
curlShader = require '../shaders/curl'
turbulenceShader = require '../shaders/turbulence'

DEBUG = true
hm = null

if DEBUG
  stats = new Stats()
  document.body.appendChild stats.domElement


class Ham
  constructor: (@runner, @canvas)->
    @time = 0
    @timeScale = 1
    @renderer = new THREE.WebGLRenderer(canvas: @canvas, antialias: false)
    @renderer.setClearColor(0x0, 1)
    @setupGUI()

  setupGUI: ->
    @gui = new GUI()
    @gui.add @, 'timeScale', 0, 5

  tick: (dt) ->
    dt = dt*0.001*@timeScale
    @time += dt
    return dt


scene = new THREE.Scene()
camera = new THREE.OrthographicCamera 1, 1, 1, 1, -500, 1000
scene.add camera

camera.position.x = 300
camera.position.y = 150
camera.position.z = 150
camera.lookAt scene.position

light1 = new THREE.PointLight 0xFFFFFF, 0.2
light2 = new THREE.PointLight 0xFFFFFF, 0.2
light3 = new THREE.PointLight 0xFFFFFF, 0.3
light4 = new THREE.PointLight 0xFFFFFF, 0.3
scene.add light1
scene.add light2
# scene.add light3
# scene.add light4
light1.position.set  800, 800, -100
light2.position.set -800, 800,  100
light3.position.set  800, 700,  800
light4.position.set -800, 700, -800

shader = turbulenceShader
  lights: false
  wireframe: false

if shader.lights
  shader.uniforms = THREE.UniformsUtils.merge([THREE.UniformsLib['lights'], shader.uniforms])
material = new THREE.ShaderMaterial shader


morphAnim = null
loader = new THREE.JSONLoader()
loader.load 'res/model/female03.json', (geom, mats) ->
  for mat, idx in mats
    if mat.name == 'DRESS.001'
      mats[idx] = material
      mat = mats[idx]
    mat.morphTargets = true

  obj = new THREE.Mesh geom, new THREE.MeshFaceMaterial mats

  scale = 500
  obj.position.y = -500
  obj.scale.multiplyScalar(scale)
  scene.add(obj)

  morphAnim = new THREE.MorphAnimation(obj)
  # I don't know why but this keeps it from blowing up
  morphAnim.frames -= 0.00001
  onLoad()



render = (context, width, height, ms) ->
  DEBUG && stats.begin()
  dts = hm.tick(ms)
  dtms = dts * 1000
  shader.uniforms.time.value += dts
  morphAnim.update(dtms*0.6)

  camera.position.x = 300*Math.sin(hm.time)
  camera.position.z = 300*Math.cos(hm.time)

  camera.lookAt scene.position
  hm.renderer.render scene, camera
  DEBUG && stats.end()


resize = (width, height) ->
  hm.renderer.setSize width, height
  aspectRatio = width/height
  height = 1000
  width = height * aspectRatio
  camera.left = width/-2
  camera.right = width/2
  camera.top = height/2
  camera.bottom = height/-2
  camera.updateProjectionMatrix()

start = (opts, width, height) ->
  # `this` is canvas-app
  hm = new Ham(this, opts.canvas)
  resize width, height
  morphAnim.play()

onLoad = ->
  testbed render,
    onReady: start
    onResize: resize
    context: 'webgl'
    canvas: document.createElement('canvas')
    once: false
    retina: true
    resizeDebounce: 100
