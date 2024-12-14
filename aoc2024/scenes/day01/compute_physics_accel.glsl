#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Buffer for charge properties
layout(binding = 0) restrict buffer ChargeIndices {
    uint charge_idxs[]; // idx used to index data in the component-arrays. Can't exceed their length.
};
layout(binding = 1) restrict buffer ChargePositions {
    vec2 charge_poss[];
};
layout(binding = 2) restrict buffer ChargeVelocities {
    vec2 charge_vels[];
};
layout(binding = 3) restrict buffer ChargeStrengths {
    float charge_strs[];
};

// Uniform block for int parameters
layout(binding = 4) uniform IntParameters {
    int num_charges;    // Number of charges, length of charge_idx
};

// Uniform block for scalar field parameters
layout(binding = 5) uniform FloatParameters {
    float deltatime;    // time since last execution. -1 if it is the first time.
    float threshold;    // Potential threshold for interaction
    float pixels_per_unit;    // Number of pixels per distance-unit (should maybe be 2 dimensions instead?)
};

// helpers
vec2 calculate_pair(uint idx1, uint idx2);
void accelerate_charge(uint idx, vec2 acc);


void main() {
    // No need to do any physics, if no time has passed
    if (deltatime <= 0) return;

    uint i = gl_GlobalInvocationID.x;
    uint j = gl_GlobalInvocationID.y;
    uint idx1 = charge_idxs[i];
    uint idx2 = charge_idxs[j];

    vec2 acc = calculate_pair(idx1, idx2);

    accelerate_charge(idx1, acc);
}


vec2 calculate_pair(in uint idx1, in uint idx2) {
    float scale_factor = 100.0;

    vec2 pos1 = charge_poss[idx1] * scale_factor;
    // vec2 vel1 = charge_vels[idx1];
    float mass1 = charge_strs[idx1];

    vec2 pos2 = charge_poss[idx2] * scale_factor;
    // vec2 vel2 = charge_vels[idx2];
    float mass2 = charge_strs[idx2];

    float k = 1.0;
    float epsilon = 1.0;
    vec2 err = pos1 - pos2;
    float lsqr = dot(err, err) + epsilon;
    float inv_l = inversesqrt(lsqr);
    float inv_l_cubed = inv_l * inv_l * inv_l;
    // vec2 norm = normalize(err);
    
    // vec2 F = k * mass1 * mass2 / lsqr
    vec2 v = err * k * inv_l_cubed; // F / (m1 * m2)
    // vec2 v = norm * k / lsqr; // F / (m1 * m2)
    // vec2 v = err * k / (lsqr * sqrt(lsqr)); // F / (m1 * m2)
    return -v * mass2 / scale_factor; // F / m1
}

void accelerate_charge(uint idx, vec2 acc) {
    charge_vels[idx] = charge_vels[idx] + acc * deltatime;
}
