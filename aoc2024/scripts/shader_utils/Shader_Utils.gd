extends RefCounted

#class_name ShaderParam
class_name Shader_Utils

class ShaderParam extends RefCounted:
    var param : Variant # RID | Array[RID]
    var type : RenderingDevice.UniformType
    
    func _init(_param : Variant, _type: RenderingDevice.UniformType) -> void:
        param = _param
        type = _type

class ShaderCache extends RefCounted:
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


static func create_param(rd: RenderingDevice, arr, uniform_type: RenderingDevice.UniformType = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, arr_size = null) -> ShaderParam:
    if not arr.to_byte_array:
        return
    var as_bytes: PackedByteArray = arr.to_byte_array()
    arr_size = arr_size if arr_size != null else as_bytes.size()
    var buffer
    if uniform_type == RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER:
        buffer = rd.storage_buffer_create(arr_size, as_bytes)
    elif uniform_type == RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER:
        buffer = rd.uniform_buffer_create(arr_size, as_bytes)
        #rd.texture_buffer_create()
    return ShaderParam.new(buffer, uniform_type)


static func create_uniforms(params: Array) -> Array[RDUniform]:
    var uniforms = []
    for i in range(params.size()):
        var uniform := RDUniform.new()
        uniform.uniform_type = params[i].type # type of the uniform (ie. "buffer" or "uniform")
        uniform.binding = i # this needs to match the "binding" in our shader file
        if params[i].type == RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE:
            uniform.add_id(params[i].param[0])
            uniform.add_id(params[i].param[1])
        else:
            uniform.add_id(params[i].param)
        uniforms.append(uniform)
        #target.append(create_uniform.call(params[i].param, i, params[i].type))
    return uniforms


static func create_shader_cache(rd: RenderingDevice, filename: String, uniforms: Array[RDUniform], dispatch: Array[int]) -> Result:
    var shader = ShaderCache.new()
    
    shader.file = load(filename)
    shader.spirv = shader.file.get_spirv()
    shader.shader = rd.shader_create_from_spirv(shader.spirv)
    if not shader.shader.is_valid():
        print("Shader failed to compile!")
        return Result.Err("Shader failed to compile.")
    print("Shader succesfully compiled.")
    
    # This can only be done after the uniforms has been prepared
    #shader.uniforms = uniforms
    #print(shader.uniforms)
    
    shader.uniform_set = rd.uniform_set_create(shader.uniforms, shader.shader, 0)
    shader.pipeline = rd.compute_pipeline_create(shader.shader)
    
    # dispatch-groups can only be calculated once these 2 are know.
    shader.invocations = dispatch[0]
    shader.workgroups = dispatch[1]
    
    return Result.Ok(shader)
