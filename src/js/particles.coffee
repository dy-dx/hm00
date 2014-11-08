
pGeometry = new THREE.Geometry()
pMaterial = new THREE.PointCloudMaterial
  color: 0x0
  size: 1

for p in [0...3000]
  # particle with random position values, -900 -> 900
  pX = Math.random() * 1800 - 900
  pY = Math.random() * 1800 - 900
  pZ = Math.random() * 1800 - 900

  pGeometry.vertices.push new THREE.Vector3(pX, pY, pZ)


particles = new THREE.PointCloud(pGeometry, pMaterial)

module.exports = particles
