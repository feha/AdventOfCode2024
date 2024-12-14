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
layout(binding = 4) uniform sampler2D scalar_field;

// Uniform block for int parameters
layout(binding = 5) uniform IntParameters {
    int num_charges;    // Number of charges, length of charge_idx
    float threshold;    // Potential threshold for interaction
};


// helpers
uint trace_pair(uint idx1, uint idx2);
void collide_pair(uint idx1, uint idx2);
void spawn_packets(uint idx);
void handle_packets_physics(uint idx);

void main() {
    uint i = gl_GlobalInvocationID.x;
    uint idx1 = charge_idxs[i];

    // Assume that all prior indices has already handled their pairing with current
    for (uint j = i + 1; j < num_charges; j++) {
        uint idx2 = charge_idxs[j];
        if (trace_pair(idx1, idx2) != 0) {
            collide_pair(idx1, idx2);
        }
    }

    // handle packets phsyics here?
    handle_packets_physics(idx1);
}

uint trace_pair(uint idx1, uint idx2) {
    if (idx1 == idx2) {
        // This is never meant to be run against itself!
        return 0;
    }

    vec2 pos1 = charge_poss[idx1];
    vec2 pos2 = charge_poss[idx2];

    uint colliding = 1;

    vec2 err = pos2 - pos1;
    uint steps = 1000;
    vec2 dir = err / steps; // not normalized, but evenly distributed instead
    for (uint n = 0; n < steps; n++) {
        vec2 sample_point = pos1 + dir * n;
        float strength = texture(scalar_field, sample_point).r;

        if (strength >= threshold) {
            colliding *= 1;
        } else {
            colliding *= 0;
        }
    }

    return colliding;
}

void collide_pair(uint idx1, uint idx2) {
    if (idx1 == idx2) {
        // This is never meant to be run against itself!
        return;
    }

    vec2 pos1 = charge_poss[idx1];
    vec2 pos2 = charge_poss[idx2];

    float mass1 = charge_strs[idx1];
    float mass2 = charge_strs[idx2];
    if (mass1 > mass2) {
        spawn_packets(idx2);
    } else if (mass1 < mass2) {
        spawn_packets(idx1);
    } else {
        // need to do something when they are equal. Give priority based on idx?
    }
}

void spawn_packets(uint idx) {
    // spawn tiny packets and add to childlist.
    // they will be repelled by parent, and attracted by scalar-field gradient.
    // they also add to the scalar-field themselves
    // - this makes them visual
    // - but also makes them "saturate" the parent's charge through the scalar-field in their direction
    //   , lowering the gradient (hopefully), such that they slowly create a chain towards closest maxima.
    // when a packet is close enough to another non-packet (that is not their parent) they get absorbed
    // A fallback is needed for when they are too old, where parent accepts them back
    // - (say it spawned packets because of larger charge A, then ate other charges and grewin size, then could eat charge A, and was left alone with its child-packets still around)
}

void handle_packets_physics(uint idx) {
    // Should this be in physics shader, or here?
}
