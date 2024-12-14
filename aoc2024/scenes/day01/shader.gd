extends Control

#@export var max_charges : int = 10
#@export var threshold_potential : float = 1.0
#@export var field_size : Vector2 = Vector2(1024, 1024)

#@onready var sprite : Sprite2D = $Sprite  # Assuming there's a Sprite2D to display the result
#var charge_positions : Array = []
#var charge_strengths : Array = []
#var charge_positions_texture : ImageTexture
#var charge_strengths_texture : ImageTexture
#var potential_image_texture : ImageTexture
#var compute_shader_material : ShaderMaterial
#
#var compute_resolution : Vector2 = Vector2(1024, 1024)  # Default compute resolution
#
#var shader
#
#func _ready():
    #custom_minimum_size = get_viewport().size
    #
    ## Initialize charge data
    #charge_positions.resize(max_charges)
    #charge_strengths.resize(max_charges)
#
    ## Create charge data
    #for i in range(max_charges):
        #charge_positions[i] = Vector2(randf_range(0, 1), randf_range(0, 1))  # Random position
        #charge_strengths[i] = randf_range(1.0, 10.0)  # Random strength
    #
    ## Set up ImageTextures for storing charge data and scalar field
    #charge_positions_texture = ImageTexture.new()
    #charge_strengths_texture = ImageTexture.new()
    #potential_image_texture = ImageTexture.new()
    #
    ## Fill charge data into textures
    #_update_charge_textures()
    
    # compute shader
    #shader = load("res://compute_shader.glsl")  # The compute shader file
    #compute_potentials()

#func _process(delta):
    #pass
    # Update charge data if needed (e.g., move charges randomly)
    #for i in range(max_charges):
        #charge_positions[i] += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * delta

    ## Update textures with the latest charge data
    #_update_charge_textures()
#
    ## Dispatch the compute shader
    #_dispatch_compute_shader()

    ## Optionally, update sprite texture to visualize the result
    #sprite.texture = potential_image_texture

#@export var output_dim : Vector2 = Vector2(1024, 1024)
#@export var threshold_potential : float = 1.0
#
#var charge_positions : Array = []
#var charge_strengths : Array = []
#
#var compute_shader : Shader
#var compute_material : ShaderMaterial
##var compute_pipeline : ComputePipeline
#var output_buffer : PackedFloat32Array
#
#func _setup_compute_shader():
    ## Load the compute shader
    #compute_material = ShaderMaterial.new()
    #compute_material.shader = compute_shader
    #
    ## Ensure input arrays are correctly set in the shader
    #var vec2_array = PackedVector2Array(charge_positions)  # Convert input_vec2_array to PackedVector2Array
    #var float_array = PackedFloat32Array(charge_strengths)  # Convert input_float_array to PackedFloat32Array
    #
    ## Create an output buffer for the compute shader
    #output_buffer = PackedFloat32Array()  # Create an empty buffer for the output
    #
    ## Set the arrays and uniforms for the compute shader
    #compute_material.set_shader_param("arr_vec2", vec2_array)
    #compute_material.set_shader_param("arr_float", float_array)
    #compute_material.set_shader_param("output_dim", output_dim)
    #compute_material.set_shader_param("threshold", threshold_potential)
    #compute_material.set_shader_param("output_arr", output_buffer)
#
#func _run_compute_shader():
    ## Create a new instance of the shader to dispatch
    #var compute_shader_instance = compute_material.shader.create_instance()
    #
    ## Calculate the number of workgroups to dispatch (using 16x16 workgroup size)
    #var work_groups = Vector3(int(output_dim.x / 16), int(output_dim.y / 16), 1)
    #
    ## Dispatch the compute shader
    #compute_shader_instance.dispatch(work_groups)

## With renderingserver
#@export var output_dim : Vector2 = Vector2(1024, 1024)
#@export var threshold_potential : float = 1.0
#
#var charge_positions : Array = []  # Array of Vector2s
#var charge_strengths : Array = []  # Array of floats
#
#var compute_shader : Shader
#var compute_material : ShaderMaterial
#var local_device : RID  # Local rendering device for compute shader
#var output_buffer : RID  # Output buffer for the results
#var charge_positions_buffer : RID  # Buffer for charge positions
#var charge_strengths_buffer : RID  # Buffer for charge strengths
#
#func _ready():
    #_setup_rendering_server()
    #_setup_compute_shader()
    #_run_compute_shader()
#
#func _setup_rendering_server():
    ## Create a local rendering device (required for compute shaders)
    #local_device = RenderingServer.create_local_rendering_device()
#
    ## Create the buffers for input and output
    #charge_positions_buffer = RenderingServer.create_buffer(RenderingServer.BUFFER_ARRAY, charge_positions.size(), false)
    #charge_strengths_buffer = RenderingServer.create_buffer(RenderingServer.BUFFER_ARRAY, charge_strengths.size(), false)
    #output_buffer = RenderingServer.create_buffer(RenderingServer.BUFFER_ARRAY, output_dim.x * output_dim.y, true)  # Output buffer for results
#
    ## Convert data to suitable format (use Array, not Packed arrays)
    #var charge_positions_flat = PoolVector2Array(charge_positions)  # Use PoolVector2Array for the buffer
    #var charge_strengths_flat = PoolRealArray(charge_strengths)  # Use PoolRealArray for the buffer
#
    ## Upload the data to the GPU
    #RenderingServer.buffer_set_data(charge_positions_buffer, charge_positions_flat)
    #RenderingServer.buffer_set_data(charge_strengths_buffer, charge_strengths_flat)
    #
    ## Set up the shader resource
    #compute_shader = load("res://path_to_your_shader.gdshader")
#
#func _setup_compute_shader():
    ## Create a ShaderMaterial and bind the compute shader to it
    #compute_material = ShaderMaterial.new()
    #compute_material.shader = compute_shader
    #
    ## Set shader parameters
    #compute_material.set_shader_param("output_dim", output_dim)
    #compute_material.set_shader_param("threshold_potential", threshold_potential)
#
    ## Set the input/output buffers
    #compute_material.set_shader_param("charge_positions", charge_positions_buffer)
    #compute_material.set_shader_param("charge_strengths", charge_strengths_buffer)
    #compute_material.set_shader_param("output_arr", output_buffer)
#
#func _run_compute_shader():
    ## Create a compute pipeline for the shader
    #var compute_pipeline = RenderingServer.create_compute_pipeline(compute_shader, local_device)
    #
    ## Dispatch the compute shader
    #var work_group_size = Vector3(int(output_dim.x / 16), int(output_dim.y / 16), 1)  # Assuming 16x16 workgroup size
    #RenderingServer.compute_dispatch(compute_pipeline, work_group_size)
    #
    ## After dispatch, you can optionally read back the result
    #var result_data = RenderingServer.buffer_get_data(output_buffer)
    #print(result_data)  # Optionally, process the result data as needed


# With renderingserver 2
@export var num_charges : int = (1 << 9) + 61 # Intentionally add a non-multiple of WORKGROUP_SIZE_1D (to ensure things work with remainders after the division)
@export var max_charge : float = 1111.0
@export var output_dim : Vector2i = Vector2i(2560, 1440)#Vector2i(3840, 2160)#Vector2i((1 << 12) + 61, (1 << 10) + 61) # Intentionally add a non-multiple of WORKGROUP_SIZE_2D (to ensure things work with remainders after the division)
@export var output_pixels_per_unit : float = 10.0
@export var threshold_potential : float = 0.01

var min_workgroup_size : int = 64
var target_workgroup_size : int = min_workgroup_size << 4 # Needs to be a multiple of the min size
var target_workgroup_log : int = int(log(target_workgroup_size) / log(2))#target_workgroup_size.bit_length()#int(log2(target_workgroup_size))
var target_workgroup_log_2d : int = target_workgroup_log / 2
var target_workgroup_log_3d : int = target_workgroup_log / 3
var WORKGROUP_SIZE_1D : Vector3 = Vector3(target_workgroup_size, 1, 1) # 64, 1,1 # Using Vector3 because when we later scale with `x / WORKGROUP_SIZE_1D` we want to round up, not down.
var WORKGROUP_SIZE_2D : Vector3 = Vector3(1 << target_workgroup_log_2d, 1 << target_workgroup_log_2d, 1) # 8,8, 1
var WORKGROUP_SIZE_3D : Vector3 = Vector3(1 << target_workgroup_log_3d, 1 << target_workgroup_log_3d, 1 << target_workgroup_log_3d) # 4, 4, 4 

var deltatime : float = -1

var charge_idxs : Array = []  # Array of idxs (think ECS)
var charge_positions : Array = []  # Array of Vector2s
var charge_velocities : Array = []
var charge_strengths : Array = []  # Array of 

var output_array : PackedFloat32Array  # Output buffer for the results

var compute_shader : Shader
var compute_material : ShaderMaterial
var local_device : RenderingDevice  # Local rendering device for compute shader

var shaders : Dictionary
var shader_pipeline : Array

#var charge_idxs_buffer : RID  # Buffer for charge positions
#var charge_positions_buffer : RID  # Buffer for charge positions
#var charge_strengths_buffer : RID  # Buffer for charge strengths
#var int_block_buffer : RID  # Buffer for ints
#var float_block_buffer : RID  # Buffer for floats
#var output_buffer : RID  # Buffer for output
#var output_image: Image
#var output_texture: ImageTexture
var output_texture_rid: RID
var output_sampler_rid: RID
#var input_texture_rid: RID

var charge_idxs_param : ShaderParam  # Buffer for charge positions
var charge_positions_param : ShaderParam  # Buffer for charge positions
var charge_velocities_param : ShaderParam  # Buffer for charge positions
var charge_strengths_param : ShaderParam  # Buffer for charge strengths
var int_block_param : ShaderParam  # Buffer for ints
var float_block_param : ShaderParam  # Buffer for floats
var output_param : ShaderParam  # Buffer for output
var output_texture_param: ShaderParam

var uniforms_scalar_field : Array
var uniforms_scalar_field_clear : Array
var uniforms_physics : Array
var uniforms_absorb : Array

class ShaderParam:
    var param
    var type : RenderingDevice.UniformType
    
    func _init(_param, _type: RenderingDevice.UniformType) -> void:
        param = _param
        type = _type

class ShaderStuff:
    var filename: String
    var file: Resource
    var spirv: RDShaderSPIRV
    var shader: RID
    # dispatch depends on `.invocations` and `.workgroups` in a way that requires ceil(float-division) (Rounding down would make the lost remainder*workgroup_size indices not get computed).
    # So we give them actual properties that in turn powers `.dispatch` automatically and allows to avoid the hassle of remembering to convert to float + ceil everytime we set it.
    var invocations: Vector3 = Vector3(1,1,1) :
        set(value):
            invocations = value
            dispatch = ceil(invocations / workgroups)
    var workgroups: Vector3 = Vector3(1,1,1) :
        set(value):
            workgroups = value
            dispatch = ceil(invocations / workgroups)
    var dispatch: Vector3i = Vector3i(1,1,1)
    var uniforms: Array = []
    var uniform_set: RID
    var pipeline: RID
    #var compute_list: RID
    
    #func _init(_shader: RID = None, _pipeline: RID, _dispatch: Vector3i) -> void:
        #shader = _shader
        #pipeline = _pipeline
        #dispatch = _dispatch

func _ready():
    self.anchor_left = 0
    self.anchor_top = 0
    self.anchor_right = 1
    self.anchor_bottom = 1
    
    #self.custom_minimum_size = get_viewport().size
    
    print(get_viewport().size)
    print(self.material)
    
    ## Initialize charge data
    charge_idxs.resize(num_charges)
    charge_positions.resize(num_charges)
    charge_velocities.resize(num_charges)
    charge_strengths.resize(num_charges)
    
    for i in range(num_charges):
        charge_idxs[i] = i
        charge_positions[i] = Vector2(randf_range(0, 1), randf_range(0, 1))  # Random position
        charge_velocities[i] = Vector2(0,0)#Vector2(randf_range(0, 1), randf_range(0, 1))  # Random velocity
        charge_strengths[i] = max_charge#randf_range(max_charge / 10.0, max_charge)  # Random strength
    
    #print(charge_positions)
    #print(charge_strengths)
    
    _setup_rendering_server()
    
    _setup_charge_buffers()
    _setup_charge_uniforms()
    
    _setup_compute_shader_pipeline()
    
    #_setup_shader_compute_physics()
    #_setup_shader_compute_scalar_field()
    #_setup_shader_compute_absorb()
    
    #var i = 0
    #var idx := local_device.buffer_get_data(charge_idxs_param.param).to_int32_array()[i]
    #var pos := local_device.buffer_get_data(charge_positions_param.param).to_float32_array()
    #var vel := local_device.buffer_get_data(charge_velocities_param.param).to_float32_array()
    #var stren := local_device.buffer_get_data(charge_strengths_param.param).to_float32_array()[idx]
    #print("[pre] first: index %s: pos=[%s, %s], vel=[%s, %s], str=%s" % [idx, pos[idx*2], pos[idx*2+1], vel[idx*2], vel[idx*2+1], stren])
    
    _create_compute_shader_compute_list()
    
    _run_compute_shader_pipeline()
    
    _setup_display_shader()
    
    ### Read back the data from the buffer
    #idx = local_device.buffer_get_data(charge_idxs_param.param).to_int32_array()[i]
    #pos = local_device.buffer_get_data(charge_positions_param.param).to_float32_array()
    #vel = local_device.buffer_get_data(charge_velocities_param.param).to_float32_array()
    #stren = local_device.buffer_get_data(charge_strengths_param.param).to_float32_array()[idx]
    #print("[post] first: index %s: pos=[%s, %s], vel=[%s, %s], str=%s" % [idx, pos[idx*2], pos[idx*2+1], vel[idx*2], vel[idx*2+1], stren])
    ##var output_bytes := local_device.buffer_get_data(charge_positions_param.param)
    ##var _output := output_bytes.to_float32_array()
    ##print(_output)

var time_since_last_frame = 0.0
func _process(delta):
    #var i = 0
    #var idx := local_device.buffer_get_data(charge_idxs_param.param).to_int32_array()[i]
    #var pos := local_device.buffer_get_data(charge_positions_param.param).to_float32_array()
    #var vel := local_device.buffer_get_data(charge_velocities_param.param).to_float32_array()
    #var stren := local_device.buffer_get_data(charge_strengths_param.param).to_float32_array()[idx]
    #print("[pre]: index %s: pos=[%s, %s], vel=[%s, %s], str=%s" % [idx, pos[idx*2], pos[idx*2+1], vel[idx*2], vel[idx*2+1], stren])
    var float_size = 4 # bytes
    var deltatime_idx = 0
    var offset = deltatime_idx * float_size
    var as_byte_arr = PackedByteArray()
    as_byte_arr.resize(float_size)
    as_byte_arr.encode_float(0, delta)
    local_device.buffer_update(float_block_param.param, offset, float_size, as_byte_arr)
    
    # cpu-wise accel:
    #float_size = 4
    #var vec2_num = 2
    #var vec2_size = float_size * vec2_num
    #var bytes_to_vec2s = func(bytes_arr: PackedByteArray):
        #var out = PackedVector2Array()
        #out.resize(bytes_arr.size() / vec2_size)
        #for i in range(0, bytes_arr.size(), vec2_size):
            #out[i/vec2_size] = Vector2(bytes_arr.decode_float(i), bytes_arr.decode_float(i + float_size))
        #return out
    #
    #var indices := local_device.buffer_get_data(charge_idxs_param.param).to_int32_array()
    ##var positions_bytes := local_device.buffer_get_data(charge_positions_param.param).to_float32_array()
    ##var velocities_bytes := local_device.buffer_get_data(charge_velocities_param.param).to_float32_array()
    #var positions_bytes := local_device.buffer_get_data(charge_positions_param.param)
    #var velocities_bytes := local_device.buffer_get_data(charge_velocities_param.param)
    ##var positions : PackedVector2Array = bytes_to_vec2s.call(positions_bytes)
    ##var velocities : PackedVector2Array = bytes_to_vec2s.call(velocities_bytes)
    #var strengths := local_device.buffer_get_data(charge_strengths_param.param).to_float32_array()
    #var scale_factor = 100.0
    #var k = 1.0
    #var epsilon = 1.0
    #for i in num_charges:
        #for j in range(i+1, num_charges):
            #var idx1 = indices[i]
            #var idx2 = indices[j]
            #var idx1_vec2 = idx1 * vec2_size
            #var idx2_vec2 = idx2 * vec2_size
            #var idx1_vec2_y = idx1_vec2+float_size
            #var idx2_vec2_y = idx2_vec2+float_size
            #
            #var pos1 = Vector2(positions_bytes.decode_float(idx1_vec2), positions_bytes.decode_float(idx1_vec2_y)) * scale_factor
            #var pos2 = Vector2(positions_bytes.decode_float(idx2_vec2), positions_bytes.decode_float(idx2_vec2_y)) * scale_factor
            ##var pos1 = positions[idx1] * scale_factor
            ##var pos2 = positions[idx2] * scale_factor
            #var mass1 = strengths[idx1]
            #var mass2 = strengths[idx2]
            #
            #var err = pos1 - pos2
            #var lsqr = err.dot(err) + epsilon
            #var l_cubed = lsqr * sqrt(lsqr)
            #
            #var v = err * k / l_cubed
            #var a1 = -v * mass2 / scale_factor
            #var a2 = v * mass1 / scale_factor
            #
            #velocities_bytes.encode_float(idx1_vec2, velocities_bytes.decode_float(idx1_vec2) + a1.x * delta)
            #velocities_bytes.encode_float(idx1_vec2_y, velocities_bytes.decode_float(idx1_vec2_y) + a1.y * delta)
            #velocities_bytes.encode_float(idx2_vec2, velocities_bytes.decode_float(idx2_vec2) + a2.x * delta)
            #velocities_bytes.encode_float(idx2_vec2_y, velocities_bytes.decode_float(idx2_vec2_y) + a2.y * delta)
            ##velocities[idx1] = velocities[idx1] + a1 * delta;
            ##velocities[idx2] = velocities[idx2] + a2 * delta;
            ##velocities[idx1*vec2_num] = velocities[idx1*vec2_num] + a1.x * delta;
            ##velocities[idx1*vec2_num+1] = velocities[idx1*vec2_num+1] + a1.y * delta;
            ##velocities[idx2*vec2_num] = velocities[idx2*vec2_num] + a2.x * delta;
            ##velocities[idx2*vec2_num+1] = velocities[idx2*vec2_num+1] + a2.y * delta;
            ##var vel1_x = velocities[idx1*vec2_num] + a1 * delta;
            ##var vel1_y = velocities[idx1*vec2_num+1] + a1 * delta;
            ##var vel2_x = velocities[idx2*vec2_num] + a2 * delta;
            ##var vel2_y = velocities[idx2*vec2_num+1] + a2 * delta;
            ##as_byte_arr = PackedByteArray()
            ##as_byte_arr.resize(vec2_size)
            ##as_byte_arr.encode_float(0 * float_size, vel1_x)
            ##as_byte_arr.encode_float(1 * float_size, vel1_y)
            ##local_device.buffer_update(charge_velocities_param.param, idx1 * vec2_size, as_byte_arr.size(), as_byte_arr)
        ##var vel_as_bytes = PackedVector2Array(velocities).to_byte_array()
        ##local_device.buffer_update(charge_velocities_param.param, 0, vel_as_bytes.size(), vel_as_bytes)
        #local_device.buffer_update(charge_velocities_param.param, 0, velocities_bytes.size(), velocities_bytes)
    
    
    _create_compute_shader_compute_list()
    _run_compute_shader_pipeline()
    
    var framerate = 120.0 # frames per second
    var time_per_frame = 1.0 / framerate # seconds per frame
    time_since_last_frame = time_since_last_frame + delta
    if time_since_last_frame > time_per_frame:
        time_since_last_frame = 0.0
        _update_display_shader()
    #idx = local_device.buffer_get_data(charge_idxs_param.param).to_int32_array()[i]
    #pos = local_device.buffer_get_data(charge_positions_param.param).to_float32_array()
    #vel = local_device.buffer_get_data(charge_velocities_param.param).to_float32_array()
    #stren = local_device.buffer_get_data(charge_strengths_param.param).to_float32_array()[idx]
    #print("[post]: index %s: pos=[%s, %s], vel=[%s, %s], str=%s" % [idx, pos[idx*2], pos[idx*2+1], vel[idx*2], vel[idx*2+1], stren])

func _setup_charge_buffers():
    var create_param = func(arr, uniform_type: RenderingDevice.UniformType = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, arr_size = null):
        if not arr.to_byte_array:
            return
        var as_bytes: PackedByteArray = arr.to_byte_array()
        arr_size = arr_size if arr_size != null else as_bytes.size()
        var buffer
        if uniform_type == RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER:
            buffer = local_device.storage_buffer_create(arr_size, as_bytes)
        elif uniform_type == RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER:
            buffer = local_device.uniform_buffer_create(arr_size, as_bytes)
            #local_device.texture_buffer_create()
        
        return ShaderParam.new(buffer, uniform_type)
    
    # Create a storage buffer for each buffer array
    charge_idxs_param = create_param.call(PackedInt32Array(charge_idxs))
    charge_positions_param = create_param.call(PackedVector2Array(charge_positions))
    charge_velocities_param = create_param.call(PackedVector2Array(charge_velocities))
    charge_strengths_param = create_param.call(PackedFloat32Array(charge_strengths))
    # And create uniforms
    int_block_param = create_param.call(PackedInt32Array([num_charges, output_dim.x, output_dim.y, 0]), RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER)
    float_block_param = create_param.call(PackedFloat32Array([deltatime, threshold_potential, output_pixels_per_unit, 0]), RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER)
    # Also output buffers
    output_array = PackedFloat32Array()  # Create an empty buffer for the output
    var output_size = output_dim.x * output_dim.y * 4  # 4 bytes per float
    output_param = create_param.call(output_array, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, output_size)
        
    var format = RDTextureFormat.new()
    format.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
    format.width = output_dim.x
    format.height = output_dim.y
    format.usage_bits = \
            RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + \
            RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + \
            RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
    output_texture_rid = local_device.texture_create(format, RDTextureView.new())
    
    var sampler_state : RDSamplerState = RDSamplerState.new()
    sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
    sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
    #sampler_state.wrap_mode = RDSamplerState.WRAP_REPEAT
    output_sampler_rid = local_device.sampler_create(sampler_state)
    #output_image = Image.new()
    #output_image = Image.create(output_dim.x, output_dim.y, false, Image.FORMAT_RGBA8)
    #output_texture = ImageTexture.new()
    #output_texture = ImageTexture.create_from_image(output_image)
    #if output_texture:
        #print("ImageTexture created successfully!")
    #else:
        #print("Failed to create ImageTexture!")
    #var output_size = output_dim.x * output_dim.y * 4  # 4 bytes per float
    #output_param = create_param.call(output_array, RenderingDevice.UNIFORM_TYPE_TEXTURE_BUFFER, output_size)
    
    
    # Create an output buffer for the compute shader
    #output_image = Image.new()
    #output_image = Image.create(output_dim.x, output_dim.y, false, Image.FORMAT_RGBA8)
    #output_texture = ImageTexture.new()
    #output_texture = ImageTexture.create_from_image(output_image)
    #if output_texture:
        #print("ImageTexture created successfully!")
    #else:
        #print("Failed to create ImageTexture!")
    #format = RDTextureFormat.new()
    #format.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
    #format.width = output_dim.x
    #format.height = output_dim.y
    #format.usage_bits = \
            #RenderingDevice.TEXTURE_USAGE_CPU_READ_BIT + \
            #RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + \
            #RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + \
            #RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
    #input_texture_rid = local_device.texture_create(format, RDTextureView.new())
    #print(local_device.texture_is_valid(output_texture_rid))
    #print(local_device.texture_is_valid(input_texture_rid))
    
    #var scalar_field_params = [
        #charge_idxs_param,
        #charge_positions_param,
        ##charge_velocities_param,
        #charge_strengths_param,
        #int_block_param,
        #float_block_param,
        #output_param,
        #ShaderParam.new(output_texture_rid, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER),
    #]
    #uniforms_scalar_field = []
    #for i in range(scalar_field_params.size()):
        #uniforms_scalar_field.append(create_uniform.call(scalar_field_params[i].param, i, scalar_field_params[i].type))

func _setup_charge_uniforms():
    #var create_uniform = func(buffer: RID, binding: int, uniform_type: RenderingDevice.UniformType):
        ## Create a uniform to assign the buffer to the rendering device
        #var uniform := RDUniform.new()
        #uniform.uniform_type = uniform_type # type of the uniform (ie. "buffer" or "uniform")
        #uniform.binding = binding # this needs to match the "binding" in our shader file
        #uniform.add_id(buffer)
        #
        #return uniform
    
    var create_uniforms = func(params: Array):
        var uniforms = []
        for i in range(params.size()):
            var uniform := RDUniform.new()
            uniform.uniform_type = params[i].type # type of the uniform (ie. "buffer" or "uniform")
            uniform.binding = i # this needs to match the "binding" in our shader file
            if params[i].type == RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE:
                #print(params[i].param[0].is_valid())
                #print(params[i].param[1].get_id())
                uniform.add_id(params[i].param[0])
                uniform.add_id(params[i].param[1])
            else:
                uniform.add_id(params[i].param)
            uniforms.append(uniform)
            #target.append(create_uniform.call(params[i].param, i, params[i].type))
        return uniforms
    
    var physics_params = [
        charge_idxs_param,
        charge_positions_param,
        charge_velocities_param,
        charge_strengths_param,
        int_block_param,
        float_block_param,
        #output_param,
        #ShaderParam.new(output_texture_rid, RenderingDevice.UNIFORM_TYPE_IMAGE),
    ]
    uniforms_physics = create_uniforms.call(physics_params)
    
    var scalar_field_params = [
        charge_idxs_param,
        charge_positions_param,
        #charge_velocities_param,
        charge_strengths_param,
        int_block_param,
        float_block_param,
        output_param,
        ShaderParam.new(output_texture_rid, RenderingDevice.UNIFORM_TYPE_IMAGE),
    ]
    uniforms_scalar_field = create_uniforms.call(scalar_field_params)
    
    var scalar_field_clear_params = [
        int_block_param,
        output_param,
        ShaderParam.new(output_texture_rid, RenderingDevice.UNIFORM_TYPE_IMAGE),
    ]
    uniforms_scalar_field_clear = create_uniforms.call(scalar_field_clear_params)
    
    var absorb_params = [
        charge_idxs_param,
        charge_positions_param,
        charge_velocities_param,
        charge_strengths_param,
        ShaderParam.new([output_texture_rid, output_sampler_rid], RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE),
        int_block_param,
        #float_block_param,
        #output_param,
        #ShaderParam.new(output_texture_rid, RenderingDevice.UNIFORM_TYPE_IMAGE),
    ]
    uniforms_absorb = create_uniforms.call(absorb_params)

func _setup_rendering_server():
    # Create a local rendering device (required for compute shaders)
    local_device = RenderingServer.create_local_rendering_device()
    
    # Load GLSL shaders
    #var shader_file := load("res://scenes/day01/compute_scalar_field.glsl")
    #var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
    #shader_scalar_field = local_device.shader_create_from_spirv(shader_spirv)
    #print("Shader compiled2: ", shader_scalar_field.is_valid())

func _setup_compute_shader_pipeline():
    # setup shaders - split into helper or such?
    # TODO definitely have them added to these lists elsewhere/in a better way.
    var shader_files = {
        physics = "res://scenes/day01/compute_physics.glsl",
        physics_accel = "res://scenes/day01/compute_physics_accel.glsl",
        physics_move = "res://scenes/day01/compute_physics_move.glsl",
        scalar_field = "res://scenes/day01/compute_scalar_field.glsl",
        scalar_field_no_loop_clear = "res://scenes/day01/compute_scalar_field_clear.glsl",
        scalar_field_no_loop = "res://scenes/day01/compute_scalar_field_no_loop.glsl",
        #absorb = "res://scenes/day01/compute_absorb.glsl",
    }
    var shader_uniforms = {
        physics = uniforms_physics,
        physics_accel = uniforms_physics,
        physics_move = uniforms_physics,
        scalar_field = uniforms_scalar_field,
        scalar_field_no_loop_clear = uniforms_scalar_field_clear,
        scalar_field_no_loop = uniforms_scalar_field,
        #absorb = uniforms_absorb,
    }
    var shader_dispatch = { # float-division so we can round up instead of down (Rounding down would make the remainder*lost_workgroup indices not get computed).
        physics = [Vector3i(num_charges, 1, 1), WORKGROUP_SIZE_1D],
        physics_accel = [Vector3i(num_charges, num_charges, 1), WORKGROUP_SIZE_2D],
        physics_move = [Vector3i(num_charges, 1, 1), WORKGROUP_SIZE_1D],
        scalar_field = [Vector3i(output_dim.x, output_dim.y, 1), Vector3(27,27,1)],#WORKGROUP_SIZE_2D],
        scalar_field_no_loop_clear = [Vector3i(output_dim.x, output_dim.y, 1), WORKGROUP_SIZE_2D],
        scalar_field_no_loop = [Vector3i(output_dim.x, output_dim.y, num_charges), WORKGROUP_SIZE_2D],
        #absorb = [Vector3i(num_charges, 1, 1), WORKGROUP_SIZE_1D]
        #physics = Vector3(Vector3i(num_charges, 1, 1)) / WORKGROUP_SIZE_1D,
        #physics_accel = Vector3(Vector3i(num_charges, num_charges, 1)) / WORKGROUP_SIZE_2D,
        #physics_move = Vector3(Vector3i(num_charges, 1, 1)) / WORKGROUP_SIZE_1D,
        #scalar_field = Vector3(Vector3i(output_dim.x, output_dim.y, 1)) / WORKGROUP_SIZE_2D,
        #scalar_field_no_loop_clear = Vector3(Vector3i(output_dim.x, output_dim.y, 1)) / WORKGROUP_SIZE_2D,
        #scalar_field_no_loop = Vector3(Vector3i(output_dim.x, output_dim.y, num_charges)) / WORKGROUP_SIZE_3D,
        #absorb = Vector3(Vector3i(num_charges, 1, 1)) / WORKGROUP_SIZE_1D,
    }
    
    shaders = {}
    for k in shader_files.keys():
        var shader = ShaderStuff.new()
        shader.filename = shader_files[k]
        shader.file = load(shader.filename)
        shader.spirv = shader.file.get_spirv()
        shader.shader = local_device.shader_create_from_spirv(shader.spirv)
        print("Shader compiled: ", shader.shader.is_valid())
        
        # This can only be done after the uniforms has been prepared
        shader.uniforms = shader_uniforms[k]
        
        print(k)
        print(shader.uniforms)
        shader.uniform_set = local_device.uniform_set_create(shader.uniforms, shader.shader, 0)
        shader.pipeline = local_device.compute_pipeline_create(shader.shader)
        
        # This can only be done onse the dispatch sizes are know.
        shader.invocations = shader_dispatch[k][0]
        shader.workgroups = shader_dispatch[k][1]
        #shader.dispatch = shader_dispatch[k]
        
        # Add prepared shader to dict
        shaders[k] = shader
    
    # setup pipeline
    shader_pipeline = []
    shader_pipeline.append(shaders.physics)
    #shader_pipeline.append(shaders.physics_accel)
    #shader_pipeline.append(shaders.physics_move)
    shader_pipeline.append(shaders.scalar_field)
    #shader_pipeline.append(shaders.scalar_field_no_loop_clear)
    #shader_pipeline.append(shaders.scalar_field_no_loop)
    #shader_pipeline.append(shaders.absorb)
    #shader_pipeline.append(shaders.scalar_field) # recompute scalar field, since we want to draw the latest version.

func _create_compute_shader_compute_list():
    # Create a compute list
    # Basically what I would consider a "pipeline" (unlike the actual pipeline)
    #var compute_list := local_device.compute_list_begin()
    
    for shader in shader_pipeline:
        var compute_list := local_device.compute_list_begin()
        local_device.compute_list_bind_compute_pipeline(compute_list, shader.pipeline)
        local_device.compute_list_bind_uniform_set(compute_list, shader.uniform_set, 0)
        var dispatches = ceil(shader.dispatch)
        local_device.compute_list_dispatch(compute_list, dispatches.x, dispatches.y, dispatches.z)
        local_device.compute_list_end()
    
    #local_device.compute_list_end()
        
    # Create a compute pipeline
    # Basically what I consider "create/load a compute shader"
    #var pipeline := local_device.compute_pipeline_create(shader)
    
    # Create a compute list
    # Basically what I would consider a "pipeline" (unlike the above)
    #var compute_list := local_device.compute_list_begin()
    #local_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
    #local_device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    #local_device.compute_list_dispatch(compute_list, dispatch_x, dispatch_y, dispatch_z)
    #local_device.compute_list_end()
    
    #print("submit")
    local_device.submit()
    #print("submited")

func _run_compute_shader_pipeline():
    #print("sync")
    local_device.sync()
    #print("synced")

func _setup_shader_compute_physics():
    # the last parameter (the 0) needs to match the "set" in our shader file
    #var uniform_set := local_device.uniform_set_create(uniforms_scalar_field, shader_scalar_field, 0)
    shaders.physics.uniform_set = local_device.uniform_set_create(shaders.physics.uniforms, shaders.physics.shader, 0)
    
    shaders.physics.pipeline = local_device.compute_pipeline_create(shaders.physics.shader)
    
    #_setup_compute_shader_pipeline(shader_scalar_field, uniforms_scalar_field, output_dim.x, output_dim.y)
    
    # Submit to GPU and wait for sync
    #print("submit")
    #local_device.submit()
    #print("submited")

func _setup_shader_compute_scalar_field():
    # the last parameter (the 0) needs to match the "set" in our shader file
    #var uniform_set := local_device.uniform_set_create(uniforms_scalar_field, shader_scalar_field, 0)
    shaders.scalar_field.uniform_set = local_device.uniform_set_create(shaders.scalar_field.uniforms, shaders.scalar_field.shader, 0)
    
    shaders.scalar_field.pipeline = local_device.compute_pipeline_create(shaders.scalar_field.shader)

func _setup_shader_compute_absorb():
    # the last parameter (the 0) needs to match the "set" in our shader file
    #var uniform_set := local_device.uniform_set_create(uniforms_scalar_field, shader_scalar_field, 0)
    shaders.absorb.uniform_set = local_device.uniform_set_create(shaders.absorb.uniforms, shaders.absorb.shader, 0)
    
    shaders.absorb.pipeline = local_device.compute_pipeline_create(shaders.absorb.shader)

#func _run_shader_compute_physics():
    #print("sync")
    #local_device.sync()
    #print("synced")
    
    #local_device.texture_copy(output_texture_rid, input_texture_rid, Vector3(0,0,0), Vector3(0,0,0), Vector3(output_dim.x,output_dim.y,0), 0, 0, 0, 0)
    #
    ## Read back the data from the buffer
    #var output_bytes := local_device.buffer_get_data(output_buffer)
    #var _output := output_bytes.to_float32_array()
    #
    ## After dispatch, you can optionally read back the result
    #print("OUTPUT TEXTURE!!!")
    #print(local_device.texture_is_valid(output_texture_rid))
    #var blah := local_device.texture_get_data(output_texture_rid, 0)
    #if blah.is_empty():
        #print("Texture data is empty!")
    #else:
        #print("Texture data retrieved successfully.")
    #
    #var image: Image = Image.create_from_data(output_dim.x, output_dim.y, false, Image.Format.FORMAT_RF, blah)
    #if image is Image:
        #print("is image")
        ##image.lock()
        #var width = image.get_width()
        #var height = image.get_height()
        #var pixel_color = image.get_pixel(0, 0)
        #print(width)
        #print(height)
        #print(pixel_color)
        #pixel_color = image.get_pixel(10, 10)
        #print(pixel_color)
        #pixel_color = image.get_pixel(25, 25)
        #print(pixel_color)
        #pixel_color = image.get_pixel(75, 75)
        #print(pixel_color)
        #pixel_color = image.get_pixel(99, 99)
        #print(pixel_color)
        ##image.unlock()
    #else:
        #print("is NOT image")
    #
    #print("INPUT TEXTURE!!!")
    #print(local_device.texture_is_valid(input_texture_rid))
    #blah = local_device.texture_get_data(input_texture_rid, 0)
    #if blah.is_empty():
        #print("Texture data is empty!")
    #else:
        #print("Texture data retrieved successfully.")
    #
    #image = Image.create_from_data(output_dim.x, output_dim.y, false, Image.Format.FORMAT_RF, blah)
    #if image is Image:
        #print("is image")
        ##image.lock()
        #var width = image.get_width()
        #var height = image.get_height()
        #var pixel_color = image.get_pixel(0, 0)
        #print(width)
        #print(height)
        #print(pixel_color)
        #pixel_color = image.get_pixel(10, 10)
        #print(pixel_color)
        #pixel_color = image.get_pixel(25, 25)
        #print(pixel_color)
        #pixel_color = image.get_pixel(75, 75)
        #print(pixel_color)
        #pixel_color = image.get_pixel(99, 99)
        ##image.unlock()
    #else:
        #print("is NOT image")
    
    #print(_output)  # Optionally, process the result data as needed

var image: Image
var texture : ImageTexture
func _setup_display_shader():
    print("_setup_display_shader")
    @warning_ignore("shadowed_variable_base_class")
    var _size = self.get_viewport().size;
    
    #var output_bytes := local_device.buffer_get_data(output_buffer)
    #var output := output_bytes.to_float32_array()
    
    #var scalar_field = StorageBuffer.new()
    #scalar_field.set_data(output)
    
    var data = local_device.texture_get_data(output_texture_rid, 0)
    image = Image.create_from_data(output_dim.x, output_dim.y, false, Image.Format.FORMAT_RF, data)
    texture = ImageTexture.create_from_image(image)
    var shader_material = self.material as ShaderMaterial;
    shader_material.set_shader_parameter("scalar_field", texture)
    _update_display_shader()
    #var shader_material = self.material as ShaderMaterial;
    #var _display_shader = shader_material.shader;
    #
    #var image: Image = Image.create_from_data(output_dim.x, output_dim.y, false, Image.Format.FORMAT_RF, local_device.texture_get_data(output_texture_rid, 0))
    #var texture = ImageTexture.create_from_image(image)
    ##var texture = ImageTexture.new()
    ##texture.create_from_rendering_device_texture(output_texture_rid)
    #shader_material.set_shader_parameter("scalar_field", texture)
    #shader_material.set_shader_parameter("display_size", size)
    #shader_material.set_shader_parameter("field_size", output_dim)
    #
    #var uniform0 := RDUniform.new()
    #uniform0.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
    #uniform0.binding = 0
    #uniform0.add_id(output_buffer)
    #
    #var uniform_set := local_device.uniform_set_create([uniform0,], display_shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
    #
    #
    ## Create a compute pipeline
    #var pipeline := local_device.compute_pipeline_create(display_shader)
    #var compute_list := local_device.compute_list_begin()
    #local_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
    #local_device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    #local_device.compute_list_dispatch(compute_list, size.x, size.y, 1)
    #local_device.compute_list_end()
    
    # Submit to GPU and wait for sync
    #print("submit")
    #local_device.submit()
    #print("submited")
    #local_device.sync()
    #print("synced")
func _update_display_shader():
    var data = local_device.texture_get_data(output_texture_rid, 0)
    image = Image.create_from_data(output_dim.x, output_dim.y, false, Image.Format.FORMAT_RF, data)
    texture.update(image)


#func init_compute():
    ## Create a local rendering device.
    #var rd := RenderingServer.create_local_rendering_device()
    ## Load GLSL shader
    #var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
    #var shader := rd.shader_create_from_spirv(shader_spirv)

#func compute_potentials():
    ## Set up the compute shader material
    #compute_shader_material = ShaderMaterial.new()
    #compute_shader_material.shader = shader
    #sprite.material = compute_shader_material
    #
    ## Set shader parameters
    #compute_shader_material.set_shader_param("num_charges", max_charges)
    #compute_shader_material.set_shader_param("field_size", field_size)
    #compute_shader_material.set_shader_param("threshold_potential", threshold_potential)
    #compute_shader_material.set_shader_param("charge_positions_texture", charge_positions_texture)
    #compute_shader_material.set_shader_param("charge_strengths_texture", charge_strengths_texture)
    #
    ## Create and assign a texture for potential field to be rendered
    #compute_shader_material.set_shader_param("potential_image", potential_image_texture)
#
#func _update_charge_textures():
    ## Update the charge positions texture
    #var positions_image = Image.new()
    #positions_image.create(1024, 1024, false, Image.FORMAT_RGB8)
    #for i in range(max_charges):
        #positions_image.set_pixelv(Vector2(i, 0), charge_positions[i])
    #charge_positions_texture.create_from_image(positions_image)
#
    ## Update the charge strengths texture
    #var strengths_image = Image.new()
    #strengths_image.create(1024, 1024, false, Image.FORMAT_L8)
    #for i in range(max_charges):
        #strengths_image.set_pixelv(Vector2(i, 0), Color(charge_strengths[i], 0, 0))
    #charge_strengths_texture.create_from_image(strengths_image)
#
#func _dispatch_compute_shader():
    ## Set the appropriate number of work groups for the compute shader dispatch
    #var work_groups = Vector3(field_size.x / 16, field_size.y / 16, 1)
    #compute_shader_material.shader.set_uniform("work_groups", work_groups)
#
    ## Run the compute shader
    #compute_shader_material.shader.execute(work_groups.x, work_groups.y, 1)
#
#func are_in_same_contour(i, j) -> bool:
    #var charge_a_pos = charge_positions[i]
    #var charge_b_pos = charge_positions[j]
#
    ## Sample the field between the charges
    #var distance = charge_a_pos.distance_to(charge_b_pos)
    #var num_samples = int(distance / 10)  # Adjust sample density based on distance
    #var is_in_same_contour = false
    #
    #for k in range(num_samples):
        #var sample_point = charge_a_pos.linear_interpolate(charge_b_pos, float(k) / float(num_samples))
        #var sample_potential = compute_potential_at(sample_point)
        #
        #if sample_potential > threshold_potential:
            #is_in_same_contour = true
            #break
    #
    #return is_in_same_contour
