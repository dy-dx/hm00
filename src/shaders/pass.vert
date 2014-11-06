varying vec2 vUv;
varying vec3 vPos;
varying vec3 vNormal;

#ifdef USE_MORPHTARGETS
  uniform float morphTargetInfluences[ 8 ];
#endif


void main() {
  vUv = uv;
  vPos = position;
  vNormal = normal;


  vec3 objectNormal;

  vec3 transformedNormal = normalMatrix * objectNormal;

#ifdef USE_MORPHTARGETS
  vec3 morphed = vec3( 0.0 );
  morphed += ( morphTarget0 - position ) * morphTargetInfluences[ 0 ];
  morphed += ( morphTarget1 - position ) * morphTargetInfluences[ 1 ];
  morphed += ( morphTarget2 - position ) * morphTargetInfluences[ 2 ];
  morphed += ( morphTarget3 - position ) * morphTargetInfluences[ 3 ];
  morphed += ( morphTarget4 - position ) * morphTargetInfluences[ 4 ];
  morphed += ( morphTarget5 - position ) * morphTargetInfluences[ 5 ];
  morphed += ( morphTarget6 - position ) * morphTargetInfluences[ 6 ];
  morphed += ( morphTarget7 - position ) * morphTargetInfluences[ 7 ];
  morphed += position;
#endif

  vec4 mvPosition;
#ifdef USE_MORPHTARGETS
  mvPosition = modelViewMatrix * vec4(morphed, 1.0);
#else
  mvPosition = modelViewMatrix * vec4(position, 1.0);
#endif

  gl_Position = projectionMatrix * mvPosition;
}
