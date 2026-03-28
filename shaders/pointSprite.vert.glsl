#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

#include "common.h"
#include "random.h"

layout ( location = 0 ) out flat uint index;
layout ( location = 1 ) out flat float radius;
layout ( location = 2 ) out flat vec3 center;

void main () {
	// seeding the RNG process
	// seed = wangSeed;
	index = seed = gl_VertexIndex;

	// placeholder, deterministic random
	radius = gl_PointSize = 5.0f * NormalizedRandomFloat() + 3.0f;

	// similar, for position
	center = vec3( ( NormalizedRandomFloat() - 0.5f ) / GlobalData.aspectRatio, NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() / 4.0f + 0.2f + 0.1f * sin( 0.01f * GlobalData.frameNumber + gl_VertexIndex ) ) * 1.918f;
	center.x *= GlobalData.aspectRatio;

	// writing the point locations
	gl_Position = vec4( center, 1.0f );
}