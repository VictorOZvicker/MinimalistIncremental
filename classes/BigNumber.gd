class_name BigNumber

var mantissa: float
var exponent: int

var standard_format = {
	3: "K",
	6: "Mi",
	9: "Bi",
	12: "Tri",
	15: "Qa",
	18: "Qi",
	21: "Sx",
	24: "Sp",
	27: "Oc",
	30: "No",
	33: "Dc"
}

func _init(_mantissa: float = 0.0, _exponent: int = 0) -> void:
	self.mantissa = _mantissa
	self.exponent = _exponent
	normalize()

static func parseBigNumber(num: String) -> BigNumber:
	if(num.is_empty()):
		return BigNumber.new()
	
	if (not num.contains("e")):
		return BigNumber.new(num.to_float())
	
	var parts         = num.split("e")
	var mantissa_part = parts[0]
	var exponent_part = parts[1]
	
	return BigNumber.new(mantissa_part.to_float(), exponent_part.to_int())

func _to_string() -> String:
	if(self.exponent >= 3):
		return self.format_standard()
	else:
		return format_float(self.mantissa * pow(10, self.exponent))

func format_standard() -> String:
	@warning_ignore("integer_division")
	var suffix_exponent := (self.exponent / 3) * 3
	var remainder := self.exponent - suffix_exponent
	var display_mantissa := self.mantissa * pow(10, remainder)
	var suffix: String = self.standard_format.get(suffix_exponent, "")

	if suffix.is_empty():
		return format_float(self.mantissa) + "e" + format_int(self.exponent)

	return format_float(display_mantissa) + " " + suffix

func format_int(number: int) -> String:
	var regex := RegEx.new()
	
	regex.compile("(\\d)(?=(\\d{3})+(?!\\d))")
	return regex.sub(str(number), "$1.", true)

func format_float(number: float) -> String:
	var raw_str := "%.2f" % number
	if not "." in raw_str:
		raw_str += ".0"
	
	var parts        := raw_str.split(".")
	var integer_part := parts[0]
	var decimal_part := parts[1]
	
	if(decimal_part.to_int() == 0): 
		return format_int(integer_part.to_int())
	else:
		return format_int(integer_part.to_int()) + "," + decimal_part

func normalize() -> void:
	if is_nan(mantissa) or is_inf(mantissa):
		push_warning("BigNumber: mantissa inválida (NaN/Inf) — provavelmente um cálculo estourou o limite de um float. Resetando para 0.")
		mantissa = 0.0
		exponent = 0
		return

	if mantissa == 0.0:
		exponent = 0
		return
		
	var is_negative := mantissa < 0
	mantissa = abs(mantissa)
	
	# If the mantissa is 10 or larger, scale it down and increase the exponent
	while mantissa >= 10.0:
		mantissa /= 10.0
		exponent += 1
	
	# If the mantissa is below 1.0, scale it up and decrease the exponent
	while mantissa < 1.0 and exponent > 0:
		mantissa *= 10.0
		exponent -= 1

	# Restore original sign
	if is_negative:
		mantissa = -mantissa
		
	# Complete flat reset for absolute zero values
	if abs(mantissa) < 0.0001 and exponent == 0:
		mantissa = 0.0

func _to_big_number(value: Variant) -> BigNumber:
	if value is BigNumber:
		return value
	if value is int or value is float:
		return BigNumber.new(float(value), 0)
	return BigNumber.new(0.0, 0)

func to_float() -> float:
	return self.mantissa * pow(10, self.exponent)

func to_int() -> int:
	return int(self.mantissa * pow(10, self.exponent))

# log10 do valor, sem passar por pow(10, exponent) — funciona mesmo pra
# expoentes gigantes que fariam to_float() estourar pra Infinity.
func log10() -> float:
	if self.mantissa <= 0.0:
		return -INF
	return (log(self.mantissa) / log(10.0)) + self.exponent
# ==============================================================================
# OPERATORS
# ==============================================================================
func add(right: Variant) -> BigNumber:
	var b := _to_big_number(right)
	var exp_diff := self.exponent - b.exponent
	
	if exp_diff > 15: return BigNumber.new(self.mantissa, self.exponent)
	if exp_diff < -15: return BigNumber.new(b.mantissa, b.exponent)
	
	if exp_diff >= 0:
		return BigNumber.new(self.mantissa + (b.mantissa / pow(10, exp_diff)), self.exponent)
	else:
		return BigNumber.new(b.mantissa + (self.mantissa / pow(10, -exp_diff)), b.exponent)

func sub(right: Variant) -> BigNumber:
	var b := _to_big_number(right)
	var exp_diff := self.exponent - b.exponent
	
	if exp_diff > 15: return BigNumber.new(self.mantissa, self.exponent)
	if exp_diff < -15: return BigNumber.new(-b.mantissa, b.exponent)
	
	if exp_diff >= 0:
		return BigNumber.new(self.mantissa - (b.mantissa / pow(10, exp_diff)), self.exponent)
	else:
		return BigNumber.new((self.mantissa / pow(10, -exp_diff)) - b.mantissa, b.exponent)

func mul(right: Variant) -> BigNumber:
	var b := _to_big_number(right)
	return BigNumber.new(self.mantissa * b.mantissa, self.exponent + b.exponent)

func div(right: Variant) -> BigNumber:
	var b := _to_big_number(right)
	if b.mantissa == 0.0:
		push_error("BigNumber Error: Division by Zero!")
		return BigNumber.new(0.0, 0)
	return BigNumber.new(self.mantissa / b.mantissa, self.exponent - b.exponent)

func bigNumber_pow(exponent_value: float) -> BigNumber:
	if self.mantissa <= 0.0:
		return BigNumber.new(0.0, 0)

	var scaled_log10 := self.log10() * exponent_value
	var new_exponent: float = floor(scaled_log10)
	var new_mantissa := pow(10.0, scaled_log10 - new_exponent)

	return BigNumber.new(new_mantissa, int(new_exponent))
# ==============================================================================
# COMPARATORS
# ==============================================================================
func less_than(right: Variant) -> bool:
	var b := _to_big_number(right)
	if self.exponent != b.exponent:
		return self.exponent < b.exponent
	return self.mantissa < b.mantissa
	
func equal(right: Variant) -> bool:
	var b := _to_big_number(right)
	return self.exponent == b.exponent and abs(self.mantissa - b.mantissa) < 0.0001

func greater_than(right: Variant) -> bool:
	var b := _to_big_number(right)
	return b.less_than(self)

func greater_or_equal(right: Variant) -> bool:
	return greater_than(right) or equal(right)

func less_or_equal(right: Variant) -> bool:
	return less_than(right) or equal(right)

func to_floor():
	if self.exponent > 15:
		return self
	return BigNumber.new(floor(self.to_float()))

func not_zero():
	return BigNumber.new(1) if self.mantissa < 0 else self
