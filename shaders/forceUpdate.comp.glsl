#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

#include "common.h"

layout ( local_size_x = 16 ) in;

// this has to keep a consistent sign convention...
// I think the easiest way to do that is to enforce the polarity of the X, Y relationship...
	// that is, because we have to have Y>X, we have the positive force vector kept from Y acting on X, or vice versa, to keep it consistent
	// with X<Y, we are going to read the value with X and Y swapped... and invert the vector
		// with atomic floats... you maybe can just add to the two nodes directly?

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

void main () {
	if ( GlobalData.frameNumber == 0 ) {
		return; // allow the point parameter RNG to complete, first frame
	}

	// I have a linear index...
	const uint n = GlobalData.numForces;
	uint index = gl_GlobalInvocationID.x;
	if ( index >= n ) {
		return; // bounds checking
	}

	// I need to solve for the two nodes this references
	uvec2 nodesReferenced = nodeFromIndex( index );
	uint bigNode = max( nodesReferenced.x, nodesReferenced.y );
	uint lilNode = min( nodesReferenced.x, nodesReferenced.y );
	if ( bigNode == lilNode ) {
		return; // self-attraction shouldn't be possible
	}

	// load the data for these two nodes ( mass + position ) and compute the gravitational force
	float bigMass = points[ bigNode ].mass.r;
	vec3 bigPt = points[ bigNode ].position.xyz;

	float lilMass = points[ lilNode ].mass.r;
	vec3 lilPt = points[ lilNode ].position.xyz;

	vec3 displacement = lilPt - bigPt;
	float d = length( displacement );
	// calculate force, with some clamping on minimum distance
	 vec3 force = ( bigMass * lilMass ) / ( max( d * d, 0.00001f ) * d ) * displacement;
//	vec3 force = ( bigMass * lilMass ) / ( d * d * d ) * displacement;

	 float r = ( bigMass + lilMass ) / 5000.0f;
//	float r = ( bigMass + lilMass ) / 1000.0f;
	if ( d < r ) {
		force = -1.0f * ( force );
	}

	// sign convention holds that we are going to store the force that acts in xxx direction (tbd)
	forces[ index ].xyz = force;
}

