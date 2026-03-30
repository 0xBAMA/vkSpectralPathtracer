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
	// I have a linear index...
	const uint n = GlobalData.numPoints;
	uint index = gl_GlobalInvocationID.x;
	if ( index >= n ) {
		return; // bounds checking
	}

	// I need to solve for the two nodes this references
	uvec2 nodesReferenced = nodeFromIndex( index );

	// load the data for these two nodes ( mass + position ) and compute the gravitational force


	// sign convention holds that we are going to store the force that acts in xxx direction

}

