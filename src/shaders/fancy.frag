#ifdef GL_ES
    precision highp float;
#endif

uniform sampler2D tDiffuse;
uniform sampler2D tColorLUT;
varying vec2 vUv;

#pragma glslify: curlNoise = require(glsl-curl-noise)

void main() {
  vec2 position = vUv;
  vec3 noise = curlNoise(gl_FragCoord.xyz);
  gl_FragColor = vec4(noise, 1.0);
}
