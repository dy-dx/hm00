#ifdef GL_ES
  precision highp float;
#endif

uniform sampler2D tDiffuse;
uniform sampler2D tColorLUT;
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#ifdef MAX_POINT_LIGHTS
  uniform vec3 pointLightColor[MAX_POINT_LIGHTS];
  uniform vec3 pointLightPosition[MAX_POINT_LIGHTS];
  uniform float pointLightDistance[MAX_POINT_LIGHTS];
#endif

#pragma glslify: curlNoise = require(glsl-curl-noise)

void main() {
  vec4 lights = vec4(1.0);
#ifdef MAX_POINT_LIGHTS
  lights = vec4(0.0, 0.0, 0.0, 1.0);
  for (int l = 0; l < MAX_POINT_LIGHTS; l++) {
    vec3 lightDirection = normalize(vPos - pointLightPosition[l]);
    lights.rgb += clamp(dot(-lightDirection, vNormal), 0.0, 1.0)
                       * pointLightColor[l];
  }
#endif

  vec2 position = vUv;
  vec3 noise = curlNoise(gl_FragCoord.xyz);
  vec3 color = cross(noise, vNormal);

  gl_FragColor = vec4(color, 1.0) * lights;
}
