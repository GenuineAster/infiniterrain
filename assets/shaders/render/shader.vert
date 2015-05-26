#version 430

layout(location=4) in vec3 pos;
layout(location=1) in vec3 normal;
layout(location=2) in vec3 texcoords;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;
out vec3 vNormal;
out vec3 vTexcoords;
out mat4 trans;
out mat3 normaltrans;
// out vec3 col;

void main()
{
	trans = projection*view;//*model;
	normaltrans = transpose(inverse(mat3(trans)));
	vTexcoords = texcoords;
	gl_Position = vec4(pos, 1.0);
	// col = mix(vec3(0.0, 1.0, 0.0), vec3(0.3, 0.8, 0.1), (snoise(pos.xy*0.1)+1.0)/2.0);

}


