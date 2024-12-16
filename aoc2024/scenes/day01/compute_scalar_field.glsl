#[compute]
#version 450
#extension GL_EXT_shader_atomic_float : enable

layout(local_size_x = 27, local_size_y = 27, local_size_z = 1) in;

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
layout(binding = 3) restrict buffer ChargeChildrenOffsets {
    uvec2 charge_children_offsets[];
};
layout(binding = 4) restrict buffer ChargeChildrenPos {
    vec2 charge_children_pos[];
};

// Uniform block for scalar field parameters
layout(binding = 5) uniform IntParameters {
    int num_charges;    // Number of charges
    int res_x;    // Size of the scalar field (image resolution)
    int res_y;    // Size of the scalar field (image resolution)
    // ivec2 output_dim;    // Size of the scalar field (image resolution)
};
// Uniform block for scalar field parameters
layout(binding = 6) uniform FloatParameters {
    float deltatime;    // time since last execution. -1 if it is the first time.
    float threshold;    // Potential threshold for interaction
    float pixels_per_unit;    // Number of pixels per distance-unit (should maybe be 2 dimensions instead?)
};

// Output array
layout(binding = 7) buffer Output {
    float output_arr[];
};

layout(binding = 8) writeonly uniform image2D output_image; // TODO need gradients, and be readable by other shaders
// layout(binding = 5) writeonly uniform Output2 {
//     image2D output_image;
// };

shared float shared_data[gl_WorkGroupSize.x * gl_WorkGroupSize.y];

vec3 calculate_influence(vec2 uv, vec2 pos, float str);

float world_scale = 200.0; // Used to scale up the distances
float epsilon = 1.0;
void main() {
    vec2 res = ivec2(res_x, res_y);

    float scale_factor = 1.1; // Just want to see more of the screen
    vec2 res_scaled = ivec2(res_x, res_y) / scale_factor;
    
    float units_per_pixel = 1.0 / pixels_per_unit;

    vec2 world_dimensions = vec2(res_scaled.x / pixels_per_unit, res_scaled.y / pixels_per_unit);

    // // Get the 2D global workgroup position (the pixel coordinates in the output image)
    // uvec2 gid = gl_GlobalInvocationID.xy;
    // Get the local thread ID (this is our 2D index in the output array)
    ivec2 index = ivec2(gl_GlobalInvocationID.xy);
    // uint xy_workgroup_index = x + y * workgroup_size_x;
    uint charge_idx = gl_GlobalInvocationID.z;

    // Ensure we stay within the bounds of the output array
    if (index.x >= res_x || index.y >= res_y || charge_idx >= num_charges)
        return;

    // Normalize the current coordinate to [0, 1] based on the field size
    vec2 uv = vec2(gl_GlobalInvocationID.xy) / res;
    // Scale and offset to center (0.5, 0.5)
    uv = uv * scale_factor - (scale_factor - vec2(1.0, 1.0)) / 2.0;
    // And scale up to world-coordinates instead
    // vec2 world_uv = uv * res_scaled;
    // Finally, scale the world to change units from pixels to physics-units
    // world_uv = world_uv / pixels_per_unit;
    // Then offset to center (0.5, 0.5)
    // world_uv = world_uv - (res - res_scaled) / 2.0;

    vec3 potential = vec3(0.0);
    // if (charge_idx == 0)
    //     atomicExchange(output_arr[index.x + index.y * res_x], 0);
    //     shared_data[xy_workgroup_index] = 0.0;
    // barrier();

    // Compute the potential at the current pixel (UV)
    for (uint i = 0; i < num_charges; i++) {
    // for (int i = 0; i < num_charges; i++) {
        uint idx = charge_idxs[i];
        vec2 charge_pos = charge_poss[idx];  // Position of the charge
        float charge_strength = charge_strs[idx];  // Strength of the charge

        // // Calculate distance from the charge to the current pixel (UV)
        // vec2 err = (uv - charge_pos) * world_scale;
        // float distSqr = dot(err, err);
        // potential += charge_strength / (distSqr + epsilon);  // Simple inverse distance law
        potential += calculate_influence(uv, charge_pos, charge_strength);

        uvec2 children = charge_children_offsets[idx];
        uint arr_end = children.x + children.y;
        for (uint j = children.x; j < arr_end; j++) {
            vec2 child_pos = charge_children_pos[j];
            potential += calculate_influence(uv, child_pos, 1.0);
        }
    }
    // Compute the potential at the current pixel (UV)
//     uint size_z = gl_WorkGroupSize.z;
//     uint elements_per_thread = num_charges / size_z;
//     uint extra_elements = num_charges % size_z;
// 
//     uint offset = elements_per_thread * charge_idx + min(charge_idx, extra_elements);
//     uint batch_end = offset + elements_per_thread + (charge_idx < extra_elements ? 1 : 0);
//     if (size_z == 2 && num_charges == 1085 && elements_per_thread == 542 && extra_elements == 1) {
//     // if (charge_idx == 0 && offset == 0 && batch_end == 543) {
//     // if (charge_idx == 1 && offset == 543 && batch_end == 1085) {
//         for (uint i = offset; i < batch_end; i++) {
//         // for (int i = 0; i < num_charges; i++) {
//             uint idx = charge_idxs[i];
//             vec2 charge_pos = charge_poss[idx];  // Position of the charge
//             float charge_strength = charge_strs[idx];  // Strength of the charge
// 
//             // Calculate distance from the charge to the current pixel (UV)
//             vec2 err = (uv - charge_pos) * world_scale;
//             float distSqr = dot(err, err);
//             potential += charge_strength / (distSqr * distSqr + epsilon);  // Simple inverse distance law
//         }
//     }

    // Apply thresholding: potential becomes 0 if below the threshold
    if (potential.z < threshold) {
        potential.z = 0.0;
    } else {
        potential = potential;//min(potential, 1000.0);  // Clamp the potential between 0 and 1
    }

    // Write the result to the output array
    // atomicAdd(output_arr, index.x + index.y * res_x, potential);
    // barrier();
    // potential = output_arr[index.x + index.y * res_x];

    // float old_potential = charge_idx != 0 ? output_arr[index.x + index.y * res_x] : 0.0;
    // potential = potential + old_potential;
    output_arr[index.x + index.y * res_x] = potential.z;
    imageStore(output_image, index, vec4(potential, 1.0) / 100.0);
}

vec3 calculate_influence(vec2 uv, vec2 pos, float str) {
    vec2 err = (pos - uv) * world_scale;
    float distSqr = dot(err, err);
    float influence = str / (distSqr + epsilon);
    vec2 gradient = normalize(err) * influence;
    return vec3(gradient, influence);
}
