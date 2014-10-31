# $ = require 'jquery'
# _ = require 'lodash'
THREE = require 'three.js'
testbed = require 'canvas-testbed'
fancy = require '../shaders/fancy'

time = 0
renderer = null
runner = null

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
  time += dt*0.001
  camera.lookAt scene.position
  renderer.render scene, camera


resize = (width, height) ->
  renderer.setSize width, height
  aspectRatio = width/height
  height = 1000
  width = height * aspectRatio
  camera.left = width/-2
  camera.right = width/2
  camera.top = height/2
  camera.bottom = height/-2
  camera.updateProjectionMatrix()

start = (opts, width, height) ->
  runner = window.runner = this # canvas-app
  renderer = new THREE.WebGLRenderer(antialias: true, canvas: opts.canvas)
  renderer.setClearColor 0xFFFFFF, 1
  resize width, height


testbed render,
  onReady: start
  onResize: resize
  context: 'webgl'
  canvas: document.createElement('canvas')
  once: false
  retina: true
  resizeDebounce: 100
