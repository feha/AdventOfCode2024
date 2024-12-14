#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Uniform block for scalar field parameters
layout(binding = 0) uniform IntParameters {
    int num_charges;    // Number of charges
    int res_x;    // Size of the scalar field (image resolution)
    int res_y;    // Size of the scalar field (image resolution)
    // ivec2 output_dim;    // Size of the scalar field (image resolution)
};

// Output array
layout(binding = 1) writeonly buffer Output {
    float output_arr[];
};

layout(binding = 2) writeonly uniform image2D output_image;
// layout(binding = 5) writeonly uniform Output2 {
//     image2D output_image;
// };

void main() {
    ivec2 index = ivec2(gl_GlobalInvocationID.xy);
    uint index_1d = index.x + index.y * res_x;

    output_arr[index_1d] = 0.0;
    imageStore(output_image, index, vec4(0.0, 0.0, 0.0, 1.0));
}
