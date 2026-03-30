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

// storage for the bodies
layout( set = 0, binding = 1, std430 ) buffer pointBuffer {
	pointState points[];
};

// storage for the body-to-body forces
layout( set = 0, binding = 2, std430 ) buffer forceBuffer {
	vec4 forces[];
};

uvec2 nodeFromIndex ( uint index ) {
	// user is responsible for giving an index 0..N(N-1)/2
	const uint n = GlobalData.numPoints;
	const uint tnm1 = 2 * n - 1;
	uvec2 result;
	result.x = uint( floor( ( ( tnm1 ) - sqrt( ( tnm1 * tnm1 ) - 8 * index ) ) / 2 ) );
	result.y = index - ( result.x * ( tnm1 - result.x ) ) / 2 + result.x + 1;
	return result;
}

uint indexFromNode ( uvec2 node ) {
	// user is responsible for ensuring two things:
	// first, Y > X
	// second, Y != X
	const uint n = GlobalData.numPoints;
	return ( node.x * ( 2 * n - node.x - 1 ) ) / 2 + ( node.y - node.x - 1 );
}

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
	if ( GlobalData.frameNumber % 500 == 0 ) {
		// initializing the point values
		points[ gl_GlobalInvocationID.x ].position.xyz = wrap( 10.0f * vec3( NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() ) );
//		points[ gl_GlobalInvocationID.x ].position.xyz = vec3( 0.4f * NormalizedRandomFloat() - 0.2f, 0.4f * NormalizedRandomFloat() - 0.2f, 0.5f );
		 points[ gl_GlobalInvocationID.x ].velocity.xyz = 0.001f * normalize( vec3( NormalizedRandomFloat() - 0.5f, NormalizedRandomFloat() - 0.5f, 0.1f * ( NormalizedRandomFloat() - 0.5f ) ) );
		//		points[ gl_GlobalInvocationID.x ].velocity.xyz = vec3( 0.0f );
		points[ gl_GlobalInvocationID.x ].mass.x = ( 30.0f ) + 100.0f * int( NormalizedRandomFloat() * 4.7f );
	} else {
		// we need to sum over the forces acting on this body...
		uint myIndex = gl_GlobalInvocationID.x;
		float myMass = points[ myIndex ].mass.r;
		vec3 forceSum = vec3( 0.0f );
		for ( int i = 0; i < GlobalData.numPoints; i++ ) {
			if ( i == myIndex ) {
				continue; // no self-influence
			} else {
				// we need to tally forces
				uvec2 forcePick = uvec2( min( i, myIndex ), max( i, myIndex ) );

				// used to flip the force vector, if we changed the order
				float scalar = ( forcePick == uvec2( i, myIndex ) ) ? 1.0f : -1.0f;

				// also need to scale with mass... tbd
				forceSum += scalar * forces[ indexFromNode( forcePick ) ].xyz / myMass;
			}
		}
		float timeStep = 0.0001f;
		points[ myIndex ].acceleration.xyz = forceSum / points[ myIndex ].mass.r;
		points[ myIndex ].velocity.xyz += timeStep * points[ myIndex ].acceleration.xyz;
		points[ myIndex ].position.xyz += timeStep * points[ myIndex ].velocity.xyz;

		points[ myIndex ].position.xyz = wrap( points[ myIndex ].position.xyz );
	}
}