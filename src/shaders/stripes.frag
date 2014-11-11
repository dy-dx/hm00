#ifdef GL_ES
  precision highp float;
#endif

uniform float time;
uniform float brightness;
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
  float offset = -0.20 * cos(time / 2.0);
  float width = 0.20;

  float stripe = sign(sin( (vPos.y + offset) / (width / 4.0) ));
  vec3 col = vec3(stripe);

  gl_FragColor = vec4(col, 1.0) * brightness;
}
