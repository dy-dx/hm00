# $ = require 'jquery'
# _ = require 'lodash'
THREE = require 'three'
Stats = require 'stats-js'
testbed = require 'canvas-testbed'
Ham = require './ham'

DEBUG = true

if DEBUG
  stats = new Stats()
  document.body.appendChild stats.domElement


render = (context, width, height, ms) ->
  DEBUG && stats.begin()
  hm.tick(ms)
  hm.render()
  DEBUG && stats.end()

resize = (width, height) ->
  hm.renderer.setSize width, height
  hm.camera.aspect = width/height
  hm.camera.updateProjectionMatrix()

start = (opts, width, height) ->
  runner = this # canvas-app
  hm.setupRenderer(runner, opts.canvas)
  resize width, height

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

loader.load 'res/model/female04low.json', (geom, mats) ->
  hm.loadModel(geom, mats)
  onLoad()
