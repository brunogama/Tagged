/// Extension to provide operator support for Tagged types.
///
/// This file implements standard Swift operators for Tagged types while maintaining type safety.
/// The operators are implemented using proxy protocols to ensure operations are only performed
/// between Tagged values of the same type, preventing accidental mixing of semantically
/// different values.
///
/// # Overview
/// The operators extension provides familiar operator syntax for Tagged types while
/// maintaining all type safety guarantees. This means you can use standard operators
/// like +, -, *, / with Tagged values just like you would with their raw values.
///
/// # Features
/// - Standard arithmetic operators (+, -, *)
/// - Assignment operators (+=, -=, *=)
/// - Division operator (/) for floating-point types
/// - Overflow operators (&+, &-, &*) for fixed-width integers
/// - Unary negation operator (-)
///
/// # Example Usage
/// ```swift
/// // Define type-safe money amounts
/// enum USDTag {}
/// typealias USD = Tagged<USDTag, Decimal>
///
/// let price1 = USD(10.99)
/// let price2 = USD(5.99)
///
/// // Use operators naturally
/// let total = price1 + price2       // USD(16.98)
/// let discount = total * USD(0.9)    // 10% off
/// let change = price1 - price2      // USD(5.00)
/// ```

// MARK: - Additive Arithmetic Operators

/// Implements the addition operator (+) for Tagged types that conform to TaggedAdditiveArithmetic.
///
/// This operator enables natural addition syntax for Tagged values while maintaining type safety.
/// It ensures that only Tagged values of the same type can be added together.
///
/// # Example
/// ```swift
/// enum MetersTag {}
/// typealias Meters = Tagged<MetersTag, Double>
///
/// let distance1 = Meters(100)
/// let distance2 = Meters(50)
/// let total = distance1 + distance2 // Meters(150)
/// ```
///
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side Tagged value
/// - Returns: A new Tagged value representing the sum
@inlinable
public func + <T: TaggedAdditiveArithmetic>(lhs: T, rhs: T) -> T {
    T.add(lhs, rhs)
}

/// Implements the subtraction operator (-) for Tagged types that conform to TaggedAdditiveArithmetic.
///
/// This operator enables natural subtraction syntax for Tagged values while maintaining type safety.
/// It ensures that only Tagged values of the same type can be subtracted.
///
/// # Example
/// ```swift
/// let balance1 = USD(100)
/// let balance2 = USD(30)
/// let remaining = balance1 - balance2 // USD(70)
/// ```
///
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side Tagged value
/// - Returns: A new Tagged value representing the difference
@inlinable
public func - <T: TaggedAdditiveArithmetic>(lhs: T, rhs: T) -> T {
    T.subtract(lhs, rhs)
}

// MARK: - Numeric Arithmetic Operators

/// Implements the multiplication operator (*) for Tagged types that conform to TaggedNumericArithmetic.
///
/// This operator enables natural multiplication syntax for Tagged values while maintaining type safety.
/// It ensures that only Tagged values of the same type can be multiplied together.
///
/// # Example
/// ```swift
/// let price = USD(10)
/// let quantity = USD(3)
/// let total = price * quantity // USD(30)
///
/// // Also works with percentage calculations
/// let discount = total * USD(0.9) // 10% off
/// ```
///
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side Tagged value
/// - Returns: A new Tagged value representing the product
@inlinable
public func * <T: TaggedNumericArithmetic>(lhs: T, rhs: T) -> T {
    T.multiply(lhs, rhs)
}

/// Implements the multiplication-assignment operator (*=) for Tagged types.
///
/// This operator enables in-place multiplication of Tagged values while maintaining type safety.
/// It modifies the left-hand operand directly instead of creating a new value.
///
/// # Example
/// ```swift
/// var price = USD(10)
/// price *= USD(2) // price is now USD(20)
/// ```
///
/// - Parameters:
///   - lhs: Left-hand side Tagged value (modified in place)
///   - rhs: Right-hand side Tagged value
@inlinable
public func *= <T: TaggedNumericArithmetic>(lhs: inout T, rhs: T) {
    lhs = T.multiply(lhs, rhs)
}

// MARK: - Signed Numeric Operators

/// Implements the unary negation operator (-) for Tagged types that conform to TaggedSignedNumeric.
///
/// This operator enables natural negation syntax for Tagged values while maintaining type safety.
/// It returns a new value with the same magnitude but opposite sign.
///
/// # Example
/// ```swift
/// let deposit = USD(100)
/// let withdrawal = -deposit // USD(-100)
///
/// let temperature = Celsius(25)
/// let negative = -temperature // Celsius(-25)
/// ```
///
/// - Parameter operand: The Tagged value to negate
/// - Returns: A new Tagged value representing the negation
@inlinable
public prefix func - <T: TaggedSignedNumeric>(operand: T) -> T {
    T.negate(operand)
}

// MARK: - Floating Point Operators

/// Implements the division operator (/) for Tagged types that conform to TaggedFloatingPointOperations.
///
/// This operator enables natural division syntax for Tagged values while maintaining type safety.
/// The right-hand operand is of the underlying type to allow division by raw numbers.
///
/// # Example
/// ```swift
/// let total = USD(100)
/// let splitThreeWays = total / 3 // USD(33.33...)
///
/// let distance = Kilometers(10)
/// let speed = distance / 2.5 // Kilometers per hour
/// ```
///
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side underlying value
/// - Returns: A new Tagged value representing the quotient
@inlinable
public func / <T: TaggedFloatingPointOperations>(lhs: T, rhs: T.Underlying) -> T {
    T.divide(lhs, by: rhs)
}

// MARK: - Fixed Width Integer Operators

/// Implements overflow addition operator (&+) for Tagged types with FixedWidthInteger raw values.
///
/// This operator performs wrapping addition that never traps on overflow, similar to the
/// standard Swift overflow operator for integers.
///
/// # Example
/// ```swift
/// let max = UInt8ID(UInt8.max)
/// let one = UInt8ID(1)
/// let wrapped = max &+ one // Wraps to UInt8ID(0)
/// ```
///
/// - Note: Use this operator when you specifically want wrapping behavior for overflow cases.
@inlinable
public func &+ <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged<Tag, RawValue>(lhs.rawValue &+ rhs.rawValue)
}

/// Implements overflow subtraction operator (&-) for Tagged types with FixedWidthInteger raw values.
///
/// This operator performs wrapping subtraction that never traps on overflow, similar to the
/// standard Swift overflow operator for integers.
///
/// # Example
/// ```swift
/// let zero = UInt8ID(0)
/// let one = UInt8ID(1)
/// let wrapped = zero &- one // Wraps to UInt8ID(255)
/// ```
///
/// - Note: Use this operator when you specifically want wrapping behavior for overflow cases.
@inlinable
public func &- <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged<Tag, RawValue>(lhs.rawValue &- rhs.rawValue)
}

/// Implements overflow multiplication operator (&*) for Tagged types with FixedWidthInteger raw values.
///
/// This operator performs wrapping multiplication that never traps on overflow, similar to the
/// standard Swift overflow operator for integers.
///
/// # Example
/// ```swift
/// let max = UInt8ID(UInt8.max)
/// let two = UInt8ID(2)
/// let wrapped = max &* two // Wraps to UInt8ID(254)
/// ```
///
/// - Note: Use this operator when you specifically want wrapping behavior for overflow cases.
@inlinable
public func &* <Tag, RawValue: FixedWidthInteger>(
    lhs: Tagged<Tag, RawValue>,
    rhs: Tagged<Tag, RawValue>
) -> Tagged<Tag, RawValue> {
    Tagged<Tag, RawValue>(lhs.rawValue &* rhs.rawValue)
}

// MARK: - Binary Floating Point Operators

/// Implements division operator (/) for Tagged types with BinaryFloatingPoint raw values.
///
/// This operator enables natural division syntax for Tagged floating-point values while
/// maintaining type safety. It allows division of a Tagged value by its raw value type.
///
/// # Example
/// ```swift
/// let distance = Kilometers(100.0)
/// let time = 2.5 // hours
/// let speed = distance / time // Kilometers(40.0) per hour
///
/// let price = USD(50.0)
/// let portions = 3.0
/// let perPerson = price / portions // USD(16.67)
/// ```
///
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side raw value
/// - Returns: A new Tagged value representing the quotient
@inlinable
public func / <Tag, RawValue: BinaryFloatingPoint>(
    lhs: Tagged<Tag, RawValue>,
    rhs: RawValue
) -> Tagged<Tag, RawValue> {
    Tagged<Tag, RawValue>(lhs.rawValue / rhs)
}
