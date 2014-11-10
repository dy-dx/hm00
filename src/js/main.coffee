window.DEBUG = true

# $ = require 'jquery'
# _ = require 'lodash'
THREE = require 'three'
Stats = require 'stats-js'
testbed = require 'canvas-testbed'
Ham = require './ham'
audio = require './audio'


if window.DEBUG
  stats = new Stats()
  document.body.appendChild stats.domElement


render = (context, width, height, ms) ->
  window.DEBUG && stats.begin()
  hm.tick(ms)
  hm.render()
  window.DEBUG && stats.end()

resize = (width, height) ->
  hm.renderer.setSize width, height
  hm.camera.aspect = width/height
  hm.camera.updateProjectionMatrix()

start = (opts, width, height) ->
  runner = this # canvas-app
  hm.setupRenderer(runner, opts.canvas)
  resize width, height
  audio.startSound()

onLoad = ->
  testbed render,
    onReady: start
    onResize: resize
    context: 'webgl'
    canvas: document.createElement('canvas')
    once: false
    retina: true
    resizeDebounce: 100

hm = new Ham()
loader = new THREE.JSONLoader()

audio.load 'res/snd/mathbonus-fog.ogg'

loader.load 'res/model/female04low.json', (geom, mats) ->
  hm.loadModel(geom, mats)
  onLoad()
