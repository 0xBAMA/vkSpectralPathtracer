#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

layout ( local_size_x = 16, local_size_y = 16 ) in;

#include "common.h"

// the accumulator image
layout ( rgba32f, set = 0, binding = 1 ) uniform image2D image;

void main () {
	// pixel index
	ivec2 loc = ivec2( gl_GlobalInvocationID.xy );

	// generate a color value
	vec3 color = vec3( float( loc.x ^ loc.y ) / 1000.0f );

	// Average with the prior value
	vec4 prevColor = imageLoad( image, loc );
	float sampleCount = prevColor.a + 1.0f;
	const float mixFactor = 1.0f / sampleCount;
	const vec4 data = vec4( ( any( isnan( color.rgb ) ) ) ? vec3( 0.0f ) : mix( prevColor.rgb, color.rgb, mixFactor ), sampleCount );

	// store back to the running image
	imageStore( image, loc, vec4( data ) );
}