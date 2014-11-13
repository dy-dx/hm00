#ifdef GL_ES
  precision highp float;
#endif

#define PI 3.1415926535897932384626433832795

uniform float time;
uniform float brightness;
uniform float balance;
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;


void main() {
  vec2 uv = vUv;
  vec3 normal = vNormal;
  float t = time;
  vec2 p = vPos.xy;

  // orient p such that (0,0) is on the waist
  // and left-edge to right-edge is from x=-1 to x=1.
  // bottom-to-top is approx. y=-1.36 to y=1.50
  p *= 3.75;
  p.y -= 4.6;


  // stripes
  float width = 0.16; // how wide is each pair (period)
  // float balance = 0.90; // 0.5 == 50/50 black and white
  float offset = -0.4 * cos(max(0.0, time - 2.5));

  float stripe = sin((p.y + offset)*2.0*PI/width) * 0.5 + balance;
  stripe = smoothstep(0.50, 0.51, stripe);
  vec3 col = vec3(stripe);

  gl_FragColor = vec4(col, 1.0) * brightness;
}
