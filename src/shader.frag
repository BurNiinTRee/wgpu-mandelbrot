#version 450

layout(location = 0) in vec2 coordinate;

layout(location = 0) out vec4 f_color;

layout(set=0, binding=0) uniform Uniforms {
    vec2 offset;
    float scale;
    float aspect_ratio;
    int max_iters;
};

float abs_squared(vec2 z) {
    return (z.x * z.x + z.y * z.y);
}

vec2 square(vec2 z) {
    float r = z.x * z.x - z.y * z.y;
    float i = 2.0 * z.x * z.y;
    return vec2(r, i);
}

int mandelbrot(vec2 c) {
    vec2 z = vec2(0.0);
    for (int i = 1; i < max_iters; i++) {
        if (abs_squared(z) > 4.0) {
            return i;
        }
        z = square(z) + c;
    }
    return 0;
}

void main() {

    vec2 c = scale * vec2(2.0*aspect_ratio, 2.0) * coordinate - offset;
    
    int iters = mandelbrot(c);
    float color_value;
    if (iters == 0) {
        color_value = 0.0;
    } else {
        float v = iters;
        v = v / max_iters;
        color_value = v;
    }
    f_color = vec4(vec3(color_value), 1.0);
}
