#include <GL/glew.h>
#include <Program/Program.hpp>

Program::operator GLuint() {
	return m_program;
}

void Program::attach(Shader &shader) {
	glAttachShader(m_program, shader);
}

void Program::link() {
	glLinkProgram(m_program);
}

void Program::use() {
	glUseProgram(m_program);
}

void Program::transform_feedback_varyings(std::vector<std::string> varyings, GLenum attrib_mode) {
	std::vector<const char*> v(varyings.size());
	for(unsigned int i=0;i<varyings.size();++i) {
		v[i] = varyings[i].c_str();
	}
	glTransformFeedbackVaryings(m_program, varyings.size(), v.data(), attrib_mode);
}

Program::Program() {
	m_program = glCreateProgram();
}

Program::~Program() {
	glDeleteProgram(m_program);
}
