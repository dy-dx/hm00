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

light1 = new THREE.PointLight 0xFFFFFF, 0.7
light2 = new THREE.PointLight 0xFFFFFF, 0.7
light3 = new THREE.PointLight 0xFFFFFF, 0.8
light4 = new THREE.PointLight 0xFFFFFF, 0.8
scene.add light1
scene.add light2
scene.add light3
scene.add light4
light1.position.set  800, 800, -100
light2.position.set -800, 800,  100
light3.position.set  800, 700,  800
light4.position.set -800, 700, -800

fancyShader = fancy
  lights: true
  wireframe: false
  # depthWrite: false
fancyShader.uniforms = THREE.UniformsUtils.merge([THREE.UniformsLib['lights'], fancyShader.uniforms])
material = new THREE.ShaderMaterial fancyShader


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



render = (context, width, height, dt) ->
  DEBUG && stats.begin()
  hm.tick(dt)

  morphAnim.update(dt/2)

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
