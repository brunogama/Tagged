/// Extension to provide numeric operations for Tagged types while maintaining type safety.
///
/// This file implements a series of proxy protocols that mirror the standard library's numeric protocols.
/// The proxy pattern is used because we cannot directly conform Tagged to protocols like Numeric or AdditiveArithmetic
/// as they have associated types and Self requirements that would break type safety.
///
/// # Overview
/// The numeric extensions provide type-safe mathematical operations for Tagged types. This means you can
/// perform arithmetic operations on Tagged values while maintaining the compile-time guarantees that
/// prevent mixing different semantic types.
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
/// // Safe arithmetic operations
/// let total = Tagged.add(price1, price2)      // USD(16.98)
/// let discount = Tagged.multiply(total, 0.9)   // 10% off
/// ```
///
/// # Performance
/// All numeric operations are marked as `@inlinable` for optimal performance. The proxy protocols
/// add no runtime overhead compared to direct operations on the underlying types.

// MARK: - Proxy Protocol for Additive Arithmetic

/// A proxy protocol that mirrors AdditiveArithmetic while maintaining Tagged type safety.
///
/// This protocol provides basic arithmetic operations (addition and subtraction) for Tagged types
/// while ensuring type safety is maintained. It serves as a replacement for the standard library's
/// AdditiveArithmetic protocol, which cannot be directly implemented by Tagged types due to
/// Self requirements that would break type safety.
///
/// # Example
/// ```swift
/// enum MetersTag {}
/// typealias Meters = Tagged<MetersTag, Double>
///
/// let distance1 = Meters(100)
/// let distance2 = Meters(50)
///
/// let totalDistance = Tagged.add(distance1, distance2)     // Meters(150)
/// let remaining = Tagged.subtract(totalDistance, distance1) // Meters(50)
/// ```
public protocol TaggedAdditiveArithmetic {
    /// The underlying type that will perform the actual arithmetic operations.
    ///
    /// This associated type represents the raw value type that must conform to
    /// AdditiveArithmetic to provide the actual implementation of arithmetic operations.
    associatedtype Underlying

    /// The zero value for this type.
    ///
    /// This property returns a Tagged value wrapping the zero value of the underlying type.
    /// It's particularly useful for initial values in accumulations or as an identity value
    /// for addition operations.
    ///
    /// Example:
    /// ```swift
    /// let startingBalance = USD.zero // USD(0)
    /// ```
    @inlinable
    static var zero: Self { get }

    /// Adds two values of this type.
    ///
    /// This operation maintains type safety by only allowing addition between Tagged values
    /// of the same type. This prevents accidental mixing of semantically different values
    /// that share the same underlying numeric type.
    ///
    /// Example:
    /// ```swift
    /// let sum = Tagged.add(USD(10), USD(20)) // USD(30)
    /// ```
    ///
    /// - Parameters:
    ///   - lhs: The first value to add
    ///   - rhs: The second value to add
    /// - Returns: The sum of the two values
    @inlinable
    static func add(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self

    /// Subtracts one value from another.
    ///
    /// This operation maintains type safety by only allowing subtraction between Tagged values
    /// of the same type. This prevents accidental mixing of semantically different values
    /// that share the same underlying numeric type.
    ///
    /// Example:
    /// ```swift
    /// let difference = Tagged.subtract(USD(30), USD(10)) // USD(20)
    /// ```
    ///
    /// - Parameters:
    ///   - lhs: The value to subtract from
    ///   - rhs: The value to subtract
    /// - Returns: The difference between the two values
    @inlinable
    static func subtract(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self
}

/// Implementation of TaggedAdditiveArithmetic for Tagged types where the raw value is AdditiveArithmetic.
///
/// This extension provides the actual implementation of arithmetic operations by delegating to
/// the underlying raw value's implementation while maintaining the Tagged wrapper.
extension Tagged: TaggedAdditiveArithmetic
where RawValue: AdditiveArithmetic {
    public typealias Underlying = RawValue

    @inlinable
    public static var zero: Self {
        Self(RawValue.zero)
    }

    @inlinable
    public static func add(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self {
        let sum: RawValue = lhs.rawValue + rhs.rawValue
        return Self(sum)
    }

    @inlinable
    public static func subtract(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self {
        let diff: RawValue = lhs.rawValue - rhs.rawValue
        return Self(diff)
    }
}

// MARK: - Proxy Protocol for Numeric Arithmetic

/// A proxy protocol that mirrors Numeric while maintaining Tagged type safety.
///
/// This protocol extends TaggedAdditiveArithmetic to include multiplication and integer conversion,
/// similar to the standard library's Numeric protocol. It maintains type safety while allowing
/// common numeric operations.
///
/// # Example
/// ```swift
/// enum PriceTag {}
/// typealias Price = Tagged<PriceTag, Decimal>
///
/// let unitPrice = Price(10)
/// let quantity = 3
///
/// // Multiply price by quantity
/// let total = Tagged.multiply(unitPrice, Price(quantity))
/// ```
public protocol TaggedNumericArithmetic: TaggedAdditiveArithmetic {
    /// Creates a new instance from a binary integer, if possible.
    ///
    /// This initializer attempts to create a Tagged value from any BinaryInteger type.
    /// It will fail if the source value cannot be represented exactly by the underlying type.
    ///
    /// Example:
    /// ```swift
    /// let price = Price(exactly: 100) // Success
    /// let tooBig = Price(exactly: Int.max) // Might fail for Decimal
    /// ```
    ///
    /// - Parameter source: The integer value to convert
    /// - Returns: A Tagged value if the conversion was successful, nil otherwise
    init?<T>(exactly source: T)
    where T: BinaryInteger

    /// Multiplies two values of this type.
    ///
    /// This operation maintains type safety by only allowing multiplication between Tagged values
    /// of the same type. This prevents accidental mixing of semantically different values
    /// that share the same underlying numeric type.
    ///
    /// Example:
    /// ```swift
    /// let price = Price(10)
    /// let doubled = Tagged.multiply(price, Price(2)) // Price(20)
    /// ```
    ///
    /// - Parameters:
    ///   - lhs: The first value to multiply
    ///   - rhs: The second value to multiply
    /// - Returns: The product of the two values
    @inlinable
    static func multiply(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self
}

/// Implementation of TaggedNumericArithmetic for Tagged types where the raw value is Numeric.
///
/// This extension provides the actual implementation of numeric operations by delegating to
/// the underlying raw value's implementation while maintaining the Tagged wrapper.
///
/// Example:
/// ```swift
/// enum CountTag {}
/// typealias Count = Tagged<CountTag, Int>
///
/// let count = Count(5)
/// let doubled = Tagged.multiply(count, Count(2)) // Count(10)
/// ```
extension Tagged: TaggedNumericArithmetic
where RawValue: Numeric {
    @inlinable
    public init?<T>(exactly source: T)
    where T: BinaryInteger {
        guard let value = RawValue(exactly: source) else { return nil }
        self.init(value)
    }

    @inlinable
    public static func multiply(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self {
        Self(lhs.rawValue * rhs.rawValue)
    }
}

// MARK: - Proxy Protocol for Signed Numeric

/// A proxy protocol that mirrors SignedNumeric while maintaining Tagged type safety.
///
/// This protocol extends TaggedNumericArithmetic to include negation operations,
/// similar to the standard library's SignedNumeric protocol. It provides type-safe
/// operations for signed numeric types like integers and floating-point numbers.
///
/// # Example
/// ```swift
/// enum TemperatureTag {}
/// typealias Temperature = Tagged<TemperatureTag, Double>
///
/// let temp = Temperature(25.5)
/// let negated = Tagged.negate(temp) // Temperature(-25.5)
/// ```
public protocol TaggedSignedNumeric: TaggedNumericArithmetic {
    /// Negates a value of this type.
    ///
    /// This operation returns the arithmetic negation of the input value while
    /// maintaining type safety. The result has the same magnitude but the opposite sign.
    ///
    /// Example:
    /// ```swift
    /// let balance = USD(100)
    /// let debt = Tagged.negate(balance) // USD(-100)
    /// ```
    ///
    /// - Parameter operand: The value to negate
    /// - Returns: The negated value
    @inlinable
    static func negate(_ operand: Self) -> Self
}

/// Implementation of TaggedSignedNumeric for Tagged types where the raw value is SignedNumeric.
///
/// This extension provides the actual implementation of signed numeric operations by delegating to
/// the underlying raw value's implementation while maintaining the Tagged wrapper.
extension Tagged: TaggedSignedNumeric
where RawValue: SignedNumeric {
    @inlinable
    public static func negate(
        _ operand: Self
    ) -> Self {
        Self(-operand.rawValue)
    }
}

// MARK: - Proxy Protocol for Floating Point Operations

/// A proxy protocol that provides floating-point operations while maintaining Tagged type safety.
///
/// This protocol provides common floating-point operations and properties while ensuring
/// type safety is maintained. It serves as a safe way to work with Tagged floating-point values,
/// providing access to essential floating-point functionality like division, remainder calculation,
/// and various numeric properties.
///
/// # Example
/// ```swift
/// enum MetersTag {}
/// typealias Meters = Tagged<MetersTag, Double>
///
/// let distance = Meters(100.0)
/// let halfDistance = Tagged.divide(distance, by: 2.0) // Meters(50.0)
/// let rounded = distance.rounded() // Meters(100.0)
/// ```
///
/// # Properties
/// The protocol provides access to common floating-point properties:
/// - `isNormal`: Whether the value is a normal floating-point number
/// - `isFinite`: Whether the value is finite
/// - `isZero`: Whether the value is zero
/// - `isSubnormal`: Whether the value is subnormal
/// - `isInfinite`: Whether the value is infinite
/// - `isNaN`: Whether the value is NaN (Not a Number)
public protocol TaggedFloatingPointOperations {
    /// The underlying floating-point type.
    ///
    /// This associated type represents the raw floating-point type that provides
    /// the actual implementation of floating-point operations.
    associatedtype Underlying

    /// Whether this value is normal.
    ///
    /// A normal floating-point number is one that can be represented in the normal
    /// format for the type, neither subnormal, infinite, nor NaN.
    @inlinable
    var isNormal: Bool { get }

    /// Whether this value is finite.
    ///
    /// A finite number is one that is neither infinite nor NaN.
    @inlinable
    var isFinite: Bool { get }

    /// Whether this value is zero.
    ///
    /// Both positive and negative zero return true.
    @inlinable
    var isZero: Bool { get }

    /// Whether this value is subnormal.
    ///
    /// A subnormal number is closer to zero than the smallest normal number.
    @inlinable
    var isSubnormal: Bool { get }

    /// Whether this value is infinite.
    ///
    /// Both positive and negative infinity return true.
    @inlinable
    var isInfinite: Bool { get }

    /// Whether this value is NaN (Not a Number).
    @inlinable
    var isNaN: Bool { get }

    /// Divides a value by another value.
    ///
    /// This operation performs floating-point division while maintaining type safety.
    /// The divisor is of the underlying type to allow division by raw numbers.
    ///
    /// Example:
    /// ```swift
    /// let price = USD(100)
    /// let halfPrice = Tagged.divide(price, by: 2.0) // USD(50)
    /// ```
    ///
    /// - Parameters:
    ///   - lhs: The value to divide
    ///   - rhs: The value to divide by
    /// - Returns: The quotient of the division
    @inlinable
    static func divide(
        _ lhs: Self,
        by rhs: Underlying
    ) -> Self

    /// Computes the remainder of dividing this value by another.
    ///
    /// This operation calculates the remainder of floating-point division while
    /// maintaining type safety.
    ///
    /// Example:
    /// ```swift
    /// let angle = Radians(5.0)
    /// let remainder = angle.remainder(dividingBy: Radians(2.0)) // Radians(1.0)
    /// ```
    ///
    /// - Parameter other: The value to divide by
    /// - Returns: The remainder of the division
    @inlinable
    func remainder(dividingBy other: Self) -> Self

    /// Computes the square root of this value.
    ///
    /// Example:
    /// ```swift
    /// let area = SquareMeters(25.0)
    /// let sideLength = area.squareRoot() // SquareMeters(5.0)
    /// ```
    ///
    /// - Returns: The square root of this value
    @inlinable
    func squareRoot() -> Self

    /// Returns this value rounded to the nearest integer.
    ///
    /// Example:
    /// ```swift
    /// let price = USD(10.6)
    /// let rounded = price.rounded() // USD(11.0)
    /// ```
    ///
    /// - Returns: The nearest integer to this value
    @inlinable
    func rounded() -> Self

    /// The next representable value in the positive direction.
    ///
    /// This property returns the smallest value that is greater than this value.
    @inlinable
    var nextUp: Self { get }
}

/// Implementation of TaggedFloatingPointOperations for Tagged types where the raw value is FloatingPoint
extension Tagged: TaggedFloatingPointOperations
where RawValue: FloatingPoint {
    public typealias Underlying = RawValue

    @inlinable
    public var isNormal: Bool { rawValue.isNormal }

    @inlinable
    public var isFinite: Bool { rawValue.isFinite }

    @inlinable
    public var isZero: Bool { rawValue.isZero }

    @inlinable
    public var isSubnormal: Bool { rawValue.isSubnormal }

    @inlinable
    public var isInfinite: Bool { rawValue.isInfinite }

    @inlinable
    public var isNaN: Bool { rawValue.isNaN }

    @inlinable
    public static func divide(
        _ lhs: Self,
        by rhs: RawValue
    ) -> Self {
        Self(lhs.rawValue / rhs)
    }

    @inlinable
    public func remainder(
        dividingBy other: Self
    ) -> Self {
        Self(rawValue.remainder(dividingBy: other.rawValue))
    }

    @inlinable
    public func squareRoot() -> Self {
        Self(rawValue.squareRoot())
    }

    @inlinable
    public func rounded() -> Self {
        Self(rawValue.rounded())
    }

    @inlinable
    public var nextUp: Self {
        Self(rawValue.nextUp)
    }
}

/// Extension to provide magnitude property for integer Tagged types
extension Tagged
where RawValue: BinaryInteger {
    /// The magnitude of this value
    @inlinable
    public var magnitude: RawValue.Magnitude {
        rawValue.magnitude
    }
}

/// Extension to provide magnitude property for floating-point Tagged types
extension Tagged
where RawValue: FloatingPoint {
    /// The magnitude of this value
    @inlinable
    public var magnitude: RawValue {
        rawValue.magnitude
    }
}

/// Extension to provide Strideable conformance for Tagged types with Strideable raw values
extension Tagged: Strideable
where RawValue: Strideable {
    @inlinable
    public func distance(
        to other: Self
    ) -> RawValue.Stride {
        rawValue.distance(to: other.rawValue)
    }

    @inlinable
    public func advanced(
        by stride: RawValue.Stride
    ) -> Self {
        Self(rawValue.advanced(by: stride))
    }
}

/// Extension to provide absolute value for signed numeric Tagged types
extension Tagged
where RawValue: SignedNumeric & Comparable {
    /// Returns the absolute value of this value
    @inlinable
    public static func abs(_ value: Tagged) -> Self {
        Self(Swift.abs(value.rawValue))
    }
}

/// Extension to provide overflow arithmetic operations for fixed-width integer Tagged types
extension Tagged
where RawValue: FixedWidthInteger {
    @inlinable
    public static func add(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self {
        Self(lhs.rawValue &+ rhs.rawValue)
    }

    @inlinable
    public static func subtract(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self {
        Self(lhs.rawValue &- rhs.rawValue)
    }

    @inlinable
    public static func multiply(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self {
        Self(lhs.rawValue &* rhs.rawValue)
    }

    @inlinable
    public static func *= (
        lhs: inout Self,
        rhs: RawValue
    ) {
        lhs = Self(lhs.rawValue &* rhs)
    }

    @inlinable
    public static func += (
        lhs: inout Self,
        rhs: Self
    ) {
        lhs = Self(lhs.rawValue &+ rhs.rawValue)
    }

    @inlinable
    public static func -= (
        lhs: inout Self,
        rhs: Self
    ) {
        lhs = Self(lhs.rawValue &- rhs.rawValue)
    }

    @inlinable
    public static func random(in range: Range<Tagged>) -> Self {
        let lowerBound = range.lowerBound.rawValue
        let upperBound = range.upperBound.rawValue
        let random = RawValue.random(in: lowerBound..<upperBound)
        return Self(random)
    }

    @inlinable
    public static func random(in range: ClosedRange<Tagged>) -> Self {
        let lowerBound = range.lowerBound.rawValue
        let upperBound = range.upperBound.rawValue
        let random = RawValue.random(in: lowerBound...upperBound)
        return Self(random)
    }
}

// MARK: - Floating Point Division
extension Tagged where RawValue: BinaryFloatingPoint {
    @inlinable
    public static func / (
        lhs: Self,
        rhs: RawValue
    ) -> Self {
        Self(lhs.rawValue / rhs)
    }
}
