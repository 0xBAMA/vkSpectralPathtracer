#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

#include "common.h"
#include "random.h"

struct pointState {
	vec4 position;
	vec4 velocity;
	vec4 acceleration;
	vec4 mass; // mass + padding
};

layout( set = 0, binding = 1, std430 ) readonly buffer pointBuffer {
	pointState points[];
};

layout ( location = 0 ) out flat uint index;
layout ( location = 1 ) out flat float radius;
layout ( location = 2 ) out flat vec3 center;

void main () {
	// seeding the RNG process
	// seed = wangSeed;
	index = seed = gl_VertexIndex;

	// placeholder, deterministic random
//	radius = gl_PointSize = 5.0f * NormalizedRandomFloat() + 5.0f + 3.0f * sin( 0.01f * GlobalData.frameNumber );
	radius = gl_PointSize = points[ index ].mass.x / 50.0f;

	// similar, for position
//	center = vec3( ( NormalizedRandomFloat() - 0.5f ) / GlobalData.aspectRatio, NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() / 4.0f + 0.2f + 0.1f * sin( 0.01f * GlobalData.frameNumber + gl_VertexIndex ) ) * 1.918f;
	center = points[ index ].position.xyz;
	center.x *= GlobalData.aspectRatio;

	// writing the point locations
	gl_Position = vec4( center, 1.0f );
}