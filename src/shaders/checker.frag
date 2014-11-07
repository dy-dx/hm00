uniform float time;
varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

void main() {
  vec2 p = sign(sin(vPos.xy * 100.0));
  float c = p.x * p.y;
  gl_FragColor = vec4(c, c, c, 1.0);
}
