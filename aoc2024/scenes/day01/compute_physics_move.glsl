#[compute]
#version 450

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

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
void tick_charge(uint idx);


void main() {
    // No need to do any physics, if no time has passed
    if (deltatime <= 0) return;

    uint i = gl_GlobalInvocationID.x;
    uint idx1 = charge_idxs[i];

    tick_charge(idx1);
}

void tick_charge(uint idx) {
    vec2 vel = charge_vels[idx];

    // Move
    charge_poss[idx] = charge_poss[idx] + charge_vels[idx] * deltatime;

    // Drag (as if in a liquid)
    if (vel.x != 0 || vel.y != 0) { // can't normalize a vector with no length
        float damping_base = 0.1; // What should be the base-drag, that applies even in a "vacuum"?
        float damping_density = 0.0; // How strongly should the density impact the drag?
        float damping = damping_base + damping_density; // How strong the drag force should be, can be thought of as the density of a fluid
        float speedSqr = dot(vel, vel);
        float speed = sqrt(speedSqr);
        vec2 drag = normalize(vel) * damping * speed; // c * v^2
        charge_vels[idx] = vel - drag * deltatime;
    }
}
