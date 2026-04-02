#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

layout ( local_size_x = 16, local_size_y = 16 ) in;

#include "common.h"
#include "random.h"

layout ( set = 0, binding = 1 ) uniform usampler2D colorAttachment;
layout ( set = 0, binding = 2 ) uniform sampler2D depthAttachment;
layout ( rgba32f, set = 0, binding = 3 ) uniform image2D image;

void main () {
	// Computing a UV for the texture sampling operation
	// vec2 loc = ( gl_GlobalInvocationID.xy + vec2( 0.5f ) ) / imageSize( image ).xy;
	ivec2 loc = ivec2( gl_GlobalInvocationID.xy );

	// raster attachments
	const uint idVal = texelFetch( colorAttachment, loc, 0 ).r;
	const float depth = texelFetch( depthAttachment, loc, 0 ).r;

// recovering the deterministic rng
	seed = idVal - 1;
	float radius = 5.0f * NormalizedRandomFloat() + 3.0f;
	vec3 center = vec3( ( NormalizedRandomFloat() - 0.5f ) / GlobalData.aspectRatio, NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() / 2.0f ) * 1.618f;

	// store the image
	vec4 col = vec4( 1.0f );
	if ( idVal != 0 ) {
		col.rgb = vec3( NormalizedRandomFloat(), NormalizedRandomFloat(), NormalizedRandomFloat() ) * ( 0.5f * depth + 0.5f );
//		col.rgb = vec3( depth );
	//	col.rgb = vec3( center );
	//	col.rgb = vec3( 1.0f / radius );
	} else {
		col.rgb = mix( vec3( 0.0f ), imageLoad( image, loc ).rgb, 0.99f );
	}
	imageStore( image, loc, col );
}