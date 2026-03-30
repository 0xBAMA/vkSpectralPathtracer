#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

#include "common.h"
#include "random.h"

layout ( local_size_x = 16 ) in;

struct pointState {
	vec4 position;
	vec4 velocity;
	vec4 acceleration;
	vec4 mass; // mass + padding
};

layout( set = 0, binding = 1, std430 ) buffer pointBuffer {
	pointState points[];
};

vec3 wrap ( vec3 pos ) {
	if ( pos.x >  GlobalData.invAspectRatio ) pos.x -= 2.0f * GlobalData.invAspectRatio;
	if ( pos.x < -GlobalData.invAspectRatio ) pos.x += 2.0f * GlobalData.invAspectRatio;
	if ( pos.y >  1.0f ) pos.y -= 2.0f;
	if ( pos.y < -1.0f ) pos.y += 2.0f;
	if ( pos.z >  1.0f ) pos.z -= 1.0f;
	if ( pos.z < -0.0f ) pos.z += 1.0f;
	return pos;
}

void main () {
	seed = PushConstants.wangSeed + 42069 * gl_GlobalInvocationID.x;
	if ( GlobalData.frameNumber == 0 ) {
		// initializing the point values
		// points[ gl_GlobalInvocationID.x ].position.xyz = vec3( NormalizedRandomFloat(), NormalizedRandomFloat(), NormalizedRandomFloat() );
		points[ gl_GlobalInvocationID.x ].position.xyz = vec3( 0.0f, 0.0f, 0.5f );
		points[ gl_GlobalInvocationID.x ].velocity.xyz = 0.01f * normalize( vec3( NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() - 0.5f, 0.1f * ( NormalizedRandomFloat() - 0.5f ) ) );
		points[ gl_GlobalInvocationID.x ].mass.x = 10.0f * NormalizedRandomFloat() + 3.0f;
	} else {
		points[ gl_GlobalInvocationID.x ].position.xyz = wrap( points[ gl_GlobalInvocationID.x ].position.xyz + points[ gl_GlobalInvocationID.x ].velocity.xyz );
	}
}