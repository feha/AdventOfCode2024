shader_type canvas_item;

//uniform sampler2D input_texture : hint_black_white;  // Input texture for the float array values
//uniform vec2 field_dimensions : hint_range(0.0, 100.0); // Dimensions of the field to map over
//uniform vec2 texture_dimensions : hint_range(0.0, 100.0); // Dimensions of the output texture
//
//uniform vec2 scalar_field[];  // Positions of 10 charges
//uniform float threshold_potential;  // Threshold for detecting charges interacting (by magnitude)

//uniform storage_buffer scalar_field : hint_storage_buffer;
uniform sampler2D scalar_field;
//uniform vec2 display_size;
//uniform vec2 field_size;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    //vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
    
    // Get the pixel coordinates in the range [0,1] based on the fragment position
    vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE.xy;

    // Map the fragment coordinates to the field dimensions
    //vec2 field_coord = uv * field_size;

    // Sample the value from the input texture using field coordinates
    //int index = int(field_coord.x + field_coord.y * field_size.x);
    //float value = scalar_field[index];
    //float value = min(texture(scalar_field, uv * field_size).r / 3.0, 1.0);
    float value = texture(scalar_field, uv).r / 10.0;
    //float value = texture(scalar_field, FRAGCOORD.xy).r / 2.0;
    //float value = texture(scalar_field, vec2(10000.0, 10000.0)).r / 2.0;

    // Output a color based on the float value (you could use a gradient or any mapping here)
    vec3 color = vec3(value, 0.0, 0.0);  // Use the value directly as grayscale for demonstration
    //vec3 color = vec3(value, 0.0, 1.0 - value);  // Use the value directly as grayscale for demonstration
    //vec3 color = vec3(SCREEN_PIXEL_SIZE.x / 1000.0, uv.y, 0.5);  // Use the value directly as grayscale for demonstration
    //vec3 color = vec3(uv.x, 0.0, 0.0);  // Use the value directly as grayscale for demonstration

    // Set the final output color
    COLOR = vec4(color, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
