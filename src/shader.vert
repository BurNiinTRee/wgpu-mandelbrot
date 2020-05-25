#version 450

layout(location=0) in vec2 a_position;
layout(location=0) out vec2 coordinate;

void main() {
    coordinate = a_position;
    gl_Position = vec4(a_position, 0.0, 1.0);
}
