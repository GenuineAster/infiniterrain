#version 430

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

in mat4 teTrans[];
in mat3 teNormalTrans[];
in vec3 tePosition[];
uniform vec3 camera_position;
uniform int draw_water;
out vec4 col;
out vec3 gNormal;
out vec3 gTexcoords;
in mat4 trans[];

const int power = 11;
const float multiplier = 50.0;
const float threshold = -0.60;
const float threshold_ = 0.0;
const float reverse_period = 0.0125;
const float terrain_size_multiplier = 1.0;

float snoise(vec2);
float cnoise(vec2);
float pnoise(vec2,vec2);

float anoise(vec2 P) {
	return snoise(P);
}

vec3 get_col(float,bool);

void main() {
	float tmp_threshold = sign(threshold)*pow(abs(threshold), power)*multiplier;
	vec4 positions[3];
	vec4 water_positions[3];
	vec2 position;
	ivec2 icamera_position = ivec2(camera_position);
	position = ivec2(gl_in[0].gl_Position.xy)*terrain_size_multiplier;
	position += -icamera_position.xy*terrain_size_multiplier;
	float noise = anoise(position*reverse_period);
	// (...-threshold_)/(1.0-threshold_)
	positions[0] = vec4(position, (sign(noise)*pow(abs(noise), power)-threshold_)/(1.0-threshold_)*multiplier, 1.0);
	water_positions[0] = positions[0];
	water_positions[0].z = max(positions[0].z, tmp_threshold);

	position = ivec2(gl_in[1].gl_Position.xy)*terrain_size_multiplier;
	position += -icamera_position.xy*terrain_size_multiplier;
	noise = anoise(position*reverse_period);
	positions[1] = vec4(position, (sign(noise)*pow(abs(noise), power)-threshold_)/(1.0-threshold_)*multiplier, 1.0);
	water_positions[1] = positions[1];
	water_positions[1].z = max(positions[1].z, tmp_threshold);

	position = ivec2(gl_in[2].gl_Position.xy)*terrain_size_multiplier;
	position += -icamera_position.xy*terrain_size_multiplier;
	noise = anoise(position*reverse_period);
	positions[2] = vec4(position, (sign(noise)*pow(abs(noise), power)-threshold_)/(1.0-threshold_)*multiplier, 1.0);
	water_positions[2] = positions[2];
	water_positions[2].z = max(positions[2].z, tmp_threshold);

	if(draw_water == 1) {
		bool w0 = water_positions[0] != positions[0];
		bool w1 = water_positions[1] != positions[1];
		bool w2 = water_positions[2] != positions[2];
		if(w0 && w1 || w0 && w2 || w1 && w2) {
			gNormal = cross(vec3(water_positions[0] - water_positions[1]), vec3(water_positions[1] - water_positions[2]));
			gNormal = normalize(teNormalTrans[0]*gNormal);
			
			col.rgb = get_col(water_positions[0].z, true) + get_col(water_positions[1].z, true) + get_col(water_positions[2].z, true);
			col = col / 3.0;
			col.rgb = vec3(0.0, 0.0, 1.0);
			col.a = 0.7;

			// water_positions[0].z += 0.08;
			// water_positions[1].z += 0.08;
			// water_positions[2].z += 0.08;

			gl_Position = teTrans[0]*water_positions[0];
			EmitVertex();
			
			// col = get_col(water_positions[1].z);
			gl_Position = teTrans[1]*water_positions[1];
			EmitVertex();
			
			// col = get_col(water_positions[2].z);
			gl_Position = teTrans[2]*water_positions[2];
			EmitVertex();
			EndPrimitive();
		}
	}

	else if(draw_water == 0) {
		gNormal = cross(vec3(positions[0] - positions[1]), vec3(positions[1] - positions[2]));
		gNormal = normalize(teNormalTrans[0]*gNormal);

		col.rgb = get_col(positions[0].z, false) + get_col(positions[1].z, false) + get_col(positions[2].z, false);
		col = col / 3.0;
		// col.rgb = vec3(1.0, 0.0, 0.5);
		col.a = 1.0;

		gl_Position = teTrans[0]*positions[0];
		EmitVertex();
		
		// col = get_col(positions[1].z);
		gl_Position = teTrans[1]*positions[1];
		EmitVertex();
		
		// col = get_col(positions[2].z);
		gl_Position = teTrans[2]*positions[2];
		EmitVertex();
		EndPrimitive();
	}
}

vec3 get_col(float z, bool water) {
	z = sign(z)*pow(abs(z/multiplier)* (1.0 - threshold_) + threshold_, 1.0/power);
	if(z <= threshold && water) {
		return vec3(0.0, 0.0, 0.6);
	} else if (z <= threshold && !water) {
		return vec3(1.0, 1.0, 0.0);
	} else if (z <= threshold+0.05) {
		return vec3(1.0, 1.0, 0.0);
	} else if (z <= 0.85) {
		return vec3(0.1, 0.9, 0.1);
	} else if (z <= 0.92) {
		return vec3(0.7, 0.3, 0.0);
	} else {
		return vec3(1.0, 1.0, 1.0);
	}
}

//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
// 

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  // i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  // i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}


//
// GLSL textureless classic 2D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/ashima/webgl-noise
//

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 fade(vec2 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(vec2 P)
{
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod289(Pi); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;

  vec4 i = permute(permute(ix) + iy);

  vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
  vec4 gy = abs(gx) - 0.5 ;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;

  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);

  vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;  
  g01 *= norm.y;  
  g10 *= norm.z;  
  g11 *= norm.w;  

  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));

  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

// Classic Perlin noise, periodic variant
float pnoise(vec2 P, vec2 rep)
{
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
  Pi = mod289(Pi);        // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;

  vec4 i = permute(permute(ix) + iy);

  vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
  vec4 gy = abs(gx) - 0.5 ;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;

  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);

  vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
  g00 *= norm.x;  
  g01 *= norm.y;  
  g10 *= norm.z;  
  g11 *= norm.w;  

  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));

  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

