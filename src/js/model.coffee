THREE = require 'three'
shaders = require './shaders'

module.exports = class Model
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
