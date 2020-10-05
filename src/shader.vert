#version 450

layout(location=0) out vec2 coordinate;

const vec2 positions[4] = vec2[4](
    vec2(-1.0, -1.0),
    vec2(1.0, -1.0),
    vec2(-1.0, 1.0),
    vec2(1.0, 1.0)
);

void main() {
    coordinate = positions[gl_VertexIndex];
    gl_Position = vec4(coordinate, 0.0, 1.0);
}
