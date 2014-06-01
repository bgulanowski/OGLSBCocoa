//
//  StockShaders.m
//  GLTools
//
//  Created by Brent Gulanowski on 2014-06-01.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "StockShaders.h"

#define Stringify(x) #x
#define Shader_string(text) @ Stringify(text)

// Identity Shader (GLT_SHADER_IDENTITY)
// This shader does no transformations at all, and uses the current
// glColor value for fragments.
// It will shade between verticies.
NSString * const szIdentityShaderVP = Shader_string
(
 attribute vec4 vVertex;
 void main(void) {
	 gl_Position = vVertex;
 }
);

NSString * const szIdentityShaderFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 uniform vec4 vColor;
 void main(void) {
	 gl_FragColor = vColor;
 }
);

// Flat Shader (GLT_SHADER_FLAT)
// This shader applies the given model view matrix to the verticies,
// and uses a uniform color value.
NSString * const szFlatShaderVP = Shader_string
(
 uniform mat4 mvpMatrix;
 attribute vec4 vVertex;
 void main(void) {
	 gl_Position = mvpMatrix * vVertex;
 }
);

NSString * const szFlatShaderFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 uniform vec4 vColor;
 void main(void) {
	 gl_FragColor = vColor;
 }
);

// GLT_SHADER_SHADED
// Point light, diffuse lighting only
NSString * const szShadedVP = Shader_string
(
 uniform mat4 mvpMatrix;
 attribute vec4 vColor;
 attribute vec4 vVertex;
 varying vec4 vFragColor;
 void main(void) {
	 vFragColor = vColor;
	 gl_Position = mvpMatrix * vVertex;
 }
 );

NSString * const szShadedFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec4 vFragColor;
 void main(void) {
	 gl_FragColor = vFragColor;
 }
);

// GLT_SHADER_DEFAULT_LIGHT
// Simple diffuse, directional, and vertex based light
NSString * const szDefaultLightVP = Shader_string
(
 uniform mat4 mvMatrix;
 uniform mat4 pMatrix;
 varying vec4 vFragColor;
 attribute vec4 vVertex;
 attribute vec3 vNormal;
 uniform vec4 vColor;
 void main(void) {
	 mat3 mNormalMatrix;
	 mNormalMatrix[0] = mvMatrix[0].xyz;
	 mNormalMatrix[1] = mvMatrix[1].xyz;
	 mNormalMatrix[2] = mvMatrix[2].xyz;
	 vec3 vNorm = normalize(mNormalMatrix * vNormal);
	 vec3 vLightDir = vec3(0.0, 0.0, 1.0);
	 float fDot = max(0.0, dot(vNorm, vLightDir));
	 vFragColor.rgb = vColor.rgb * fDot;
	 vFragColor.a = vColor.a;
	 mat4 mvpMatrix;
	 mvpMatrix = pMatrix * mvMatrix;
	 gl_Position = mvpMatrix * vVertex;
 }
);

NSString * const szDefaultLightFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec4 vFragColor;
 void main(void) {
	 gl_FragColor = vFragColor;
 }
);

//GLT_SHADER_POINT_LIGHT_DIFF
// Point light, diffuse lighting only
NSString * const szPointLightDiffVP = Shader_string
(
 uniform mat4 mvMatrix;
 uniform mat4 pMatrix;
 uniform vec3 vLightPos;
 uniform vec4 vColor;
 attribute vec4 vVertex;
 attribute vec3 vNormal;
 varying vec4 vFragColor;
 void main(void) {
	 mat3 mNormalMatrix;
	 mNormalMatrix[0] = normalize(mvMatrix[0].xyz);
	 mNormalMatrix[1] = normalize(mvMatrix[1].xyz);
	 mNormalMatrix[2] = normalize(mvMatrix[2].xyz);
	 vec3 vNorm = normalize(mNormalMatrix * vNormal);
	 vec4 ecPosition;
	 vec3 ecPosition3;
	 ecPosition = mvMatrix * vVertex;
	 ecPosition3 = ecPosition.xyz /ecPosition.w;
	 vec3 vLightDir = normalize(vLightPos - ecPosition3);
	 float fDot = max(0.0, dot(vNorm, vLightDir));
	 vFragColor.rgb = vColor.rgb * fDot;
	 vFragColor.a = vColor.a;
	 mat4 mvpMatrix;
	 mvpMatrix = pMatrix * mvMatrix;
	 gl_Position = mvpMatrix * vVertex;
 }
);


NSString * const szPointLightDiffFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec4 vFragColor;
 void main(void) {
	 gl_FragColor = vFragColor;
 }
);
 
 //GLT_SHADER_TEXTURE_REPLACE
 // Just put the texture on the polygons
 NSString * const szTextureReplaceVP = Shader_string
(
 uniform mat4 mvpMatrix;
 attribute vec4 vVertex;
 attribute vec2 vTexCoord0;
 varying vec2 vTex;
 void main(void) {
	 vTex = vTexCoord0;
	 gl_Position = mvpMatrix * vVertex;
 }
);

NSString * const szTextureReplaceFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec2 vTex;
 uniform sampler2D textureUnit0;
 void main(void) {
	 gl_FragColor = texture2D(textureUnit0, vTex);
}
);


// Just put the texture on the polygons
NSString * const szTextureRectReplaceVP = Shader_string
(
 uniform mat4 mvpMatrix;
 attribute vec4 vVertex;
 attribute vec2 vTexCoord0;
 varying vec2 vTex;
 void main(void) {
	 vTex = vTexCoord0;
	gl_Position = mvpMatrix * vVertex;
}
);

NSString * const szTextureRectReplaceFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec2 vTex;
 uniform sampler2DRect textureUnit0;
 void main(void) {
	 gl_FragColor = texture2DRect(textureUnit0, vTex);
 }
);



//GLT_SHADER_TEXTURE_MODULATE
// Just put the texture on the polygons, but multiply by the color (as a unifomr)
NSString * const szTextureModulateVP = Shader_string
(
 uniform mat4 mvpMatrix;
 attribute vec4 vVertex;
 attribute vec2 vTexCoord0;
 varying vec2 vTex;
 void main(void) {
	 vTex = vTexCoord0;
	 gl_Position = mvpMatrix * vVertex;
 }
);

NSString * const szTextureModulateFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec2 vTex;
 uniform sampler2D textureUnit0;
 uniform vec4 vColor;
 void main(void) {
	 gl_FragColor = vColor * texture2D(textureUnit0, vTex);
 }
);


//GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF
// Point light (Diffuse only), with texture (modulated)
NSString * const szTexturePointLightDiffVP = Shader_string
(
 uniform mat4 mvMatrix;
 uniform mat4 pMatrix;
 uniform vec3 vLightPos;
 uniform vec4 vColor;
 attribute vec4 vVertex;
 attribute vec3 vNormal;
 varying vec4 vFragColor;
 attribute vec2 vTexCoord0;
 varying vec2 vTex;
 void main(void) {
	 mat3 mNormalMatrix;
	 mNormalMatrix[0] = normalize(mvMatrix[0].xyz);
	 mNormalMatrix[1] = normalize(mvMatrix[1].xyz);
	 mNormalMatrix[2] = normalize(mvMatrix[2].xyz);
	 vec3 vNorm = normalize(mNormalMatrix * vNormal);
	 vec4 ecPosition;
	 vec3 ecPosition3;
	 ecPosition = mvMatrix * vVertex;
	 ecPosition3 = ecPosition.xyz /ecPosition.w;
	 vec3 vLightDir = normalize(vLightPos - ecPosition3);
	 float fDot = max(0.0, dot(vNorm, vLightDir));
	 vFragColor.rgb = vColor.rgb * fDot;
	 vFragColor.a = vColor.a;
	 vTex = vTexCoord0;
	 mat4 mvpMatrix;
	 mvpMatrix = pMatrix * mvMatrix;
	 gl_Position = mvpMatrix * vVertex;
 }
);


NSString *szTexturePointLightDiffFP = Shader_string
(
#ifdef OPENGL_ES
 precision mediump float;
#endif
 varying vec4 vFragColor;
 varying vec2 vTex;
 uniform sampler2D textureUnit0;
 void main(void) {
	 gl_FragColor = vFragColor * texture2D(textureUnit0, vTex);
}
);

