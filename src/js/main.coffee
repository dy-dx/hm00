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
    @renderer = new THREE.WebGLRenderer(canvas: @canvas, antialias: true)
    @setupGUI()

  setupGUI: ->
    @gui = new GUI()
    @gui.add @, 'timeScale', 0, 5

  tick: (dt) ->
    @time += dt*0.001*@timeScale


scene = new THREE.Scene()
camera = new THREE.OrthographicCamera 1, 1, 1, 1, -500, 1000
scene.add camera

geometry = new THREE.BoxGeometry 600, 600, 600
material = new THREE.ShaderMaterial fancy
    wireframe: false
    # depthWrite: false

box = new THREE.Mesh geometry, material
scene.add box

light = new THREE.PointLight 0xFFFFFF
scene.add light

light.position.y = 800
light.position.z = 800
light.position.x = 800

camera.position.x = 300
camera.position.y = 150
camera.position.z = 150
camera.lookAt scene.position



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
