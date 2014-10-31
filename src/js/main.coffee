# $ = require 'jquery'
# _ = require 'lodash'
THREE = require 'three.js'

fancy = require '../shaders/fancy'


scene = new THREE.Scene()
aspectRatio = window.innerWidth / window.innerHeight
height = 1000
width = height * aspectRatio
camera = new THREE.OrthographicCamera width/-2, width/2, height/2, height/-2, -500, 1000

renderer = new THREE.WebGLRenderer(antialias: true)
renderer.setSize window.innerWidth, window.innerHeight
renderer.setClearColor 0xFFFFFF, 1
document.getElementById('container').appendChild renderer.domElement


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

render = ->
  requestAnimationFrame render
  timer = Date.now() * 0.002
  renderer.render scene, camera

render()
