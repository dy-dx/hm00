
pGeometry = new THREE.Geometry()
pMaterial = new THREE.PointCloudMaterial
  color: 0x0
  size: 0.12
  blending: THREE.AdditiveBlending
  transparent: true

for p in [0...3000]
  # particle with random position values, -90 -> 90
  pX = Math.random() * 180 - 90
  pY = Math.random() * 180 - 90
  pZ = Math.random() * 180 - 90

  pGeometry.vertices.push new THREE.Vector3(pX, pY, pZ)


particles = new THREE.PointCloud(pGeometry, pMaterial)

module.exports = particles
