#[compute]
#version 450

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

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
layout(binding = 4) restrict buffer ChargeChildrenOffsets {
    uvec2 charge_children_offsets[];
};
layout(binding = 5) restrict buffer ChargeChildrenPos {
    vec2 charge_children_pos[];
};

// Uniform block for int parameters
layout(binding = 6) uniform IntParameters {
    int num_charges;    // Number of charges, length of charge_idx
};

// Uniform block for scalar field parameters
layout(binding = 7) uniform FloatParameters {
    float deltatime;    // time since last execution. -1 if it is the first time.
    float threshold;    // Potential threshold for interaction
    float pixels_per_unit;    // Number of pixels per distance-unit (should maybe be 2 dimensions instead?)
};

// helpers
void calculate_pair(in uint idx1, in uint idx2, out vec2 a1, out vec2 a2);
void accelerate_charge(uint idx, vec2 acc);
void move_charge(uint idx);
void drag_charge(uint idx);
void tick_charge(uint idx);


float epsilon = 1.0;
float scale_factor = 500.0;
float scale_factor_inv = 1.0 / scale_factor;

void main() {
    uint i = gl_GlobalInvocationID.x;

    // Ensure we stay within the bounds of the arrays
    if (i >= num_charges)
        return;
    
    uint idx1 = charge_idxs[i];

    // No need to do any physics, if no time has passed
    if (deltatime <= 0) return;

    // Assume that all prior indices has already handled their interaction with current
    for (uint j = i + 1; j < num_charges; j++) {
        uint idx2 = charge_idxs[j];
        vec2 a1;
        vec2 a2;
        calculate_pair(idx1, idx2, a1, a2);

        accelerate_charge(idx1, a1);
        accelerate_charge(idx2, a2);
    }

    // After also having handled interactions for later indices, all interactions are finished now.
    tick_charge(idx1);
    
    uvec2 children = charge_children_offsets[idx1];
    uint arr_end = uint(children.x + children.y);
    for (uint j = children.x; j < arr_end; j++) {
        vec2 owner_pos = charge_poss[idx1] * scale_factor;
        float owner_mass = charge_strs[idx1] * scale_factor;
        vec2 child_pos = charge_children_pos[j]* scale_factor; // packet's strength = 1.0
        // TODO Move towards owner.
        vec2 err = owner_pos - child_pos;
        float lsqr = max(dot(err, err), epsilon);
        float inv_l = inversesqrt(lsqr);
        float inv_l_cubed = inv_l * inv_l * inv_l;
        charge_children_pos[j] += err * owner_mass * inv_l_cubed * 1.0;
        // // TODO Move along gradient.
        // charge_children_pos[j] = charge_children_pos[j] + gradient;
    }
}


void calculate_pair(in uint idx1, in uint idx2, out vec2 a1, out vec2 a2) {
    vec2 pos1 = charge_poss[idx1] * scale_factor;
    // vec2 vel1 = charge_vels[idx1];
    float mass1 = charge_strs[idx1];

    vec2 pos2 = charge_poss[idx2] * scale_factor;
    // vec2 vel2 = charge_vels[idx2];
    float mass2 = charge_strs[idx2];

    float k = 1.0;
    vec2 err = pos1 - pos2;
    float lsqr = max(dot(err, err), epsilon); // or addition
    float inv_l = inversesqrt(lsqr);
    float inv_l_cubed = inv_l * inv_l * inv_l;
    // vec2 norm = normalize(err);
    
    // vec2 F = k * mass1 * mass2 / lsqr
    vec2 v = err * k * inv_l_cubed; // F / (m1 * m2)
    // vec2 v = norm * k / lsqr; // F / (m1 * m2)
    // vec2 v = err * k / (lsqr * sqrt(lsqr)); // F / (m1 * m2)
    a1 = -v * mass2; // F / m1
    a2 = v * mass1; // -F / m2

    // vel1 += a1;
    // vel2 += a2;
}

void accelerate_charge(uint idx, vec2 acc) {
    charge_vels[idx] = charge_vels[idx] + acc * deltatime;
}

void move_charge(uint idx) {
    vec2 vel = charge_vels[idx];
    charge_poss[idx] = charge_poss[idx] + charge_vels[idx] * deltatime * scale_factor_inv;
}


// Drag (as if in a liquid)
void drag_charge(uint idx) {
    vec2 vel = charge_vels[idx];
    if (vel.x != 0 || vel.y != 0) { // can't normalize a vector with no length
        float damping_base = 1.0; // What should be the base-drag, that applies even in a "vacuum"?
        // float damping_base = 0.1; // What should be the base-drag, that applies even in a "vacuum"?
        float damping_density = 0.0; // How strongly should the density impact the drag?
        float damping = damping_base + damping_density; // How strong the drag force should be, can be thought of as the density of a fluid
        // float speedSqr = dot(vel, vel);
        // float speed = sqrt(speedSqr);
        // vec2 drag = normalize(vel) * damping * speed; // c * v^2
        // vec2 drag = vel * damping; // c * v^2
        // charge_vels[idx] = vel - drag * min(deltatime, 1.0);
        charge_vels[idx] = vel * (1.0 - (damping + damping) * min(deltatime, 1.0));
    }
}


void tick_charge(uint idx) {
    vec2 vel = charge_vels[idx];

    move_charge(idx);

    drag_charge(idx);
}
