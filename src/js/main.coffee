# $ = require 'jquery'
# _ = require 'lodash'
THREE = require 'three'
Stats = require 'stats-js'
GUI = require('dat-gui').GUI
testbed = require 'canvas-testbed'
fancy = require '../shaders/fancy'

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
    @setupGUI()

  setupGUI: ->
    @gui = new GUI()
    @gui.add @, 'timeScale', 0, 5

  tick: (dt) ->
    @time += dt*0.001*@timeScale


scene = new THREE.Scene()
camera = new THREE.OrthographicCamera 1, 1, 1, 1, -500, 1000
scene.add camera

camera.position.x = 300
camera.position.y = 150
camera.position.z = 150
camera.lookAt scene.position

light = new THREE.PointLight 0xFFFFFF
scene.add light

light.position.y = 800
light.position.z = 500
light.position.x = 500

fancyShader = fancy
  lights: true
  wireframe: false
  # depthWrite: false
fancyShader.uniforms = THREE.UniformsUtils.merge([THREE.UniformsLib['lights'], fancyShader.uniforms])
material = new THREE.ShaderMaterial fancyShader

loader = new THREE.OBJLoader()
loader.load 'model/male02.obj', (obj) ->
  desiredHeight = 800
  # scale obj to desired height and vertically center at y=0
  bbox = new THREE.Box3().setFromObject(obj)
  scale = desiredHeight / (bbox.max.y - bbox.min.y)
  obj.scale.multiplyScalar(scale)
  obj.position.y = -desiredHeight/2
  obj.traverse (child) ->
    if child instanceof THREE.Mesh
      child.material = material

  scene.add(obj)



render = (context, width, height, dt) ->
  DEBUG && stats.begin()
  hm.tick(dt)

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


testbed render,
  onReady: start
  onResize: resize
  context: 'webgl'
  canvas: document.createElement('canvas')
  once: false
  retina: true
  resizeDebounce: 100
