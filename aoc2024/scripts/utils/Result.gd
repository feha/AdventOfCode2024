extends RefCounted

class_name Result

var _value: Variant
var _error: StringName

static func Ok(value: Variant) -> Result:
    var result := Result.new()
    result._value = value
    return result

static func Err(_error: Variant) -> Result:
    var result := Result.new()
    result._error = _error
    return result

func is_ok() -> bool:
    return _value != null and _error == null
func is_ok_and(f: Callable) -> bool:
    return is_ok() and f.call(_value)

func is_err() -> bool:
    return _error != null and _value == null
func is_err_and(f: Callable) -> bool:
    return is_err() and f.call(_error)

func unwrap_or_else(default_f: Callable) -> Variant:
    return _value if is_ok() else default_f.call(_error)
func unwrap_or(default: Variant) -> Variant:
    return _value if is_ok() else default
func unwrap() -> Variant:
    return unwrap_or(Error.FAILED)
func unwrap_err_or_else(default_f: Callable) -> Variant:
    return _error if is_err() else default_f.call(_error)
func unwrap_err_or(default: Variant) -> Variant:
    return _error if is_err() else default
func unwrap_err() -> Variant:
    return unwrap_err_or(Error.FAILED)
#func expect(msg : String) -> Variant:
    #return unwrap()
#func expect_err(msg : String) -> Variant:
    #return unwrap()

func map(f: Callable) -> Result:
    return Ok(f.call(_value)) if is_ok() else self
func map_or(f: Callable, default: Variant) -> Variant:
    return f.call(_value) if is_ok() else default
func map_or_else(f: Callable, default_f: Callable) -> Result:
    return Ok(f.call(_value)) if is_ok() else Err(default_f.call(_error))

func map_err(f: Callable) -> Result:
    return Err(f.call(_error)) if is_err() else self
func map_err_or(f: Callable, default: Variant) -> Variant:
    return f.call(_error) if is_err() else default
func map_err_or_else(f: Callable, default_f: Callable) -> Result:
    return map_or_else(default_f, f)

func and_(res: Result) -> Result:
    return res if is_ok() else self
func and_then(f: Callable) -> Result:
    return f.call(_value) if is_ok() else self
func or_(res: Result) -> Result:
    return res if is_err() else self
func or_else(f: Callable) -> Result:
    return f.call(_error) if is_err() else self

# impl Result<Option<T>, E>
class Option:
    var _value: Variant
    static func Some(value: Variant) -> Option:
        var result := Option.new()
        result._value = value
        return result

    static func None() -> Option:
        return Option.new()

func transpose() -> Variant:
    if _value is Option:
        return Option.Some(_value) if is_ok() else Option.None()
    else:
        return Error.FAILED

# impl Result<Result<T, E>, E>
func flatten() -> Variant:
    if _value is Result:
        return _value if is_ok() else _error
    else:
        return Error.FAILED

# impl Ord
func _cmp(other) -> Variant:
    if other is Result:
        if self.is_ok() != other.is_ok():
            return -1 if is_ok() else 1
        
        var a = self._value if is_ok() else self._error
        var b = other._value if is_ok() else other._error
        return -1 if a < b else (0 if a == b else 1)
    else:
        return Error.FAILED
    
func _max(other) -> Variant:
    if other is Result:
        if self.is_ok() != other.is_ok():
            return self if is_err() else other
        
        if is_ok():
            return self if self._value >= other._value else other
        else:
            return self if self._error >= other._error else other
    else:
        return Error.FAILED

func _min(other) -> Variant:
    if other is Result:
        if self.is_ok() != other.is_ok():
            return self if is_ok() else other
        
        if is_ok():
            return self if self._value <= other._value else other
        else:
            return self if self._error <= other._error else other
    else:
        return Error.FAILED

func _clamp(min, max) -> Variant:
    if min is Result and max is Result:
        if min > max:
            return Error.FAILED
        
        return max(min, min(self, max))
    else:
        return Error.FAILED

# impl PartialEq
func _helper_neq(other):
    return self.is_ok() != other.is_ok() \
                or self._value != other._value if is_ok() else self._error != other._error

func _eq(other) -> Variant:
    if other is Result:
        return not _helper_neq(other)
    else:
        return Error.FAILED

func _neq(other) -> Variant:
    if other is Result:
        return _helper_neq(other)
    else:
        return Error.FAILED

# impl PartialOrd
func _lt(other) -> Variant:
    if other is Result:
        return self._value < other._value if self.is_ok() == other.is_ok() else is_ok()
    else:
        return Error.FAILED

func _gt(other) -> Variant:
    if other is Result:
        return self._value > other._value if self.is_ok() == other.is_ok() else not is_ok()
    else:
        return Error.FAILED

func _le(other) -> Variant:
    if other is Result:
        return self._value <= other._value if self.is_ok() == other.is_ok() else is_ok()
    else:
        return Error.FAILED

func _ge(other) -> Variant:
    if other is Result:
        return self._value >= other._value if self.is_ok() == other.is_ok() else not is_ok()
    else:
        return Error.FAILED
