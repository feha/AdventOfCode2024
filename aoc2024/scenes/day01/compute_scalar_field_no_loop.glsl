#[compute]
#version 450
#extension GL_EXT_shader_atomic_float : enable

layout(local_size_x = 4, local_size_y = 4, local_size_z = 4) in;

// Buffer for charge properties
layout(binding = 0) restrict buffer ChargeIndices {
    uint charge_idxs[]; // idx used to index data in the component-arrays. Can't exceed their length.
};
layout(binding = 1) restrict buffer ChargePositions {
    vec2 charge_poss[];
};
// layout(binding = 2) restrict buffer ChargeVelocities {
//     vec2 charge_vels[];
// };
layout(binding = 2) restrict buffer ChargeStrengths {
    float charge_strs[];
};

// Uniform block for scalar field parameters
layout(binding = 3) uniform IntParameters {
    int num_charges;    // Number of charges
    int res_x;    // Size of the scalar field (image resolution)
    int res_y;    // Size of the scalar field (image resolution)
    // ivec2 output_dim;    // Size of the scalar field (image resolution)
};
// Uniform block for scalar field parameters
layout(binding = 4) uniform FloatParameters {
    float deltatime;    // time since last execution. -1 if it is the first time.
    float threshold;    // Potential threshold for interaction
    float pixels_per_unit;    // Number of pixels per distance-unit (should maybe be 2 dimensions instead?)
};

// Output array
layout(binding = 5) buffer Output {
    float output_arr[];
};

layout(binding = 6) writeonly uniform image2D output_image;
// layout(binding = 5) writeonly uniform Output2 {
//     image2D output_image;
// };

void main() {
    ivec2 res = ivec2(res_x, res_y);
    vec2 world_dimensions = vec2(res_x / pixels_per_unit, res_y / pixels_per_unit);

    // // Get the 2D global workgroup position (the pixel coordinates in the output image)
    // uvec2 gid = gl_GlobalInvocationID.xy;
    // Get the local thread ID (this is our 2D index in the output array)
    ivec2 index = ivec2(gl_GlobalInvocationID.xy);
    uint index_1d = index.x + index.y * res.x;

    // // Ensure we stay within the bounds of the output array
    // if (index.x >= res.x || index.y >= res.y)
    //     return;

    // Normalize the current coordinate to [0, 1] based on the field size
    vec2 uv = vec2(gl_GlobalInvocationID.xy) / res;
    // And scale up to world-coordinates instead
    vec2 world_uv = uv * world_dimensions;

    // Compute the potential at the current pixel (UV)
    uint i = gl_GlobalInvocationID.z;

    float epsilon = 1;
    uint idx = charge_idxs[i];
    vec2 charge_pos = charge_poss[idx] * world_dimensions;  // Position of the charge
    float charge_strength = charge_strs[idx];  // Strength of the charge

    // Calculate distance from the charge to the current pixel (UV)
    vec2 err = world_uv - charge_pos;
    float dist = dot(err, err);
    atomicAdd(output_arr[index_1d], charge_strength / (dist + epsilon));  // Simple inverse distance law
    float potential = output_arr[index_1d];

    // Apply thresholding: potential becomes 0 if below the threshold
    if (potential < threshold) {
        potential = 0.0;
    } else {
        potential = potential;//min(potential, 1000.0);  // Clamp the potential between 0 and 1
    }

    // Write the result to the output array
    output_arr[index_1d] = potential;
    imageStore(output_image, index, vec4(potential, 0.0, 0.0, 1.0));
}
