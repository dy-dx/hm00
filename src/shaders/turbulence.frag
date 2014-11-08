#ifdef GL_ES
  precision highp float;
#endif

uniform sampler2D tDiffuse;
uniform sampler2D tColorLUT;
uniform float time;
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#pragma glslify: snoise2 = require(glsl-noise/simplex/2d)

float turbulence(vec2 position, float lacunarity, float gain) {
  vec2 uv = vUv;
  vec3 normal = vNormal;

  float sum = 0.0;
  float scale = 1.0;
  float totalGain = 1.0;
  const int octaves = 3;
  for (int i = 0; i < octaves; ++i) {
    sum += totalGain * snoise2(position*scale);
    scale *= lacunarity;
    totalGain *= gain;
  }
  return abs(sum);
}

void main() {
  vec2 uv = vUv;
  float t = time;
  float lacunarity = 3.0;

  vec2 p = vPos.xy;
  float q = turbulence(p, lacunarity, 0.8);

  vec3 color = vec3( 1.0, 1.0, 1.0 );

  float r = snoise2( vec2(400.0 + t*1.2 + q*2.0, 1.0) );

  color *= smoothstep( r, r+0.08, 0.3);

  gl_FragColor = vec4(color, 1.0);
}
