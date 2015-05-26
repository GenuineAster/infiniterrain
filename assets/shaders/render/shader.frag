#version 430

layout(depth_unchanged) out float gl_FragDepth;
layout(early_fragment_tests) in;

in vec3 gNormal;
in vec3 gTexcoords;
in vec3 col;
out vec4 outNormal;
out vec4 outColor;

// uniform sampler2DArray spritesheet;

void main()
{
	outNormal = vec4(gNormal, 1.0);
	// outColor = texture(spritesheet, vTexcoords);
	// outColor = vec4(1.0, 0.0, 0.0, 1.0);
	outColor = vec4(col, 1.0);
}
