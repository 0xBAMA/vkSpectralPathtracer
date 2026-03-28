#version 460

#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_buffer_reference : require

#include "common.h"

layout ( location = 0 ) out uint outFragID;

// depth_greater or depth_less once I know what's going on with it
layout ( depth_any ) out float gl_FragDepth;

layout ( location = 0 ) in flat uint index;
layout ( location = 1 ) in flat float radius;
layout ( location = 2 ) in flat vec3 center;

void main () {
	// this eventually needs a jitter, too
	vec2 sampleLocation = gl_PointCoord.xy;

	// analytic solution for sphere mask/height via pythagoras
	vec2 centered = sampleLocation * 2.0f - vec2( 1.0f );
	float radiusSquared = dot( centered, centered );
	if ( radiusSquared > 1.0f ) discard;
	float sphereHeightSample = sqrt( 1.0f - radiusSquared );

	// computing a depth value...
		// we know the position of the center of the sphere...
		// we know the radius of the sphere...
		// we know this fragment's normalv(similar to mask)...

	// so we can calculate a worldspace position here...
	vec3 fragNormal = vec3( centered, sphereHeightSample );
	vec3 worldspacePos = center + fragNormal * ( radius / float( GlobalData.floatBufferResolution ) );
	gl_FragDepth = worldspacePos.z;

	outFragID = index + 1;
}