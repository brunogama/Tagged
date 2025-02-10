// swiftlint:disable file_length
//
//  Tagged+Numeric.swift
//  Tagged
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import Foundation

/// Extension to provide numeric operations for Tagged types while maintaining type safety.
///
/// This file implements a series of proxy protocols that mirror the standard library's numeric protocols.
/// The proxy pattern is used because we cannot directly conform Tagged to protocols like Numeric or AdditiveArithmetic
/// as they have associated types and Self requirements that would break type safety.
///
/// Instead, we create our own protocols that provide similar functionality while maintaining the type safety
/// guarantees of Tagged types. This allows us to use mathematical operations on Tagged values while ensuring
/// we don't accidentally mix different semantic types.

// MARK: - Proxy Protocol for Additive Arithmetic

/// A proxy protocol that mirrors AdditiveArithmetic while maintaining Tagged type safety
///
/// This protocol provides basic arithmetic operations (addition and subtraction) for Tagged types
/// while ensuring type safety is maintained. It serves as a replacement for the standard library's
/// AdditiveArithmetic protocol, which cannot be directly implemented by Tagged types due to
/// Self requirements that would break type safety.
public protocol TaggedAdditiveArithmetic {
    /// The underlying type that will perform the actual arithmetic operations
    associatedtype Underlying

    /// The zero value for this type
    @inlinable
    static var zero: Self { get }

    /// Adds two values of this type
    /// - Parameters:
    ///   - lhs: The first value to add
    ///   - rhs: The second value to add
    /// - Returns: The sum of the two values
    @inlinable
    static func add(
        _ lhs: Self,
        _ rhs: Self
    ) -> Self

    /// Subtracts one value from another
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

/// Implementation of TaggedAdditiveArithmetic for Tagged types where the raw value is AdditiveArithmetic
extension Tagged: TaggedAdditiveArithmetic
where TagRawValue: AdditiveArithmetic {
    public typealias Underlying = TagRawValue

    @inlinable
    public static var zero: Tagged<TypeTag, TagRawValue> {
        Tagged(TagRawValue.zero)
    }

    @inlinable
    public static func add(
        _ lhs: Tagged<TypeTag, TagRawValue>,
        _ rhs: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        let sum: TagRawValue = lhs.rawValue + rhs.rawValue
        return Tagged<TypeTag, TagRawValue>(sum)
    }

    @inlinable
    public static func subtract(
        _ lhs: Tagged<TypeTag, TagRawValue>,
        _ rhs: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        let diff: TagRawValue = lhs.rawValue - rhs.rawValue
        return Tagged<TypeTag, TagRawValue>(diff)
    }
}

// MARK: - Proxy Protocol for Numeric Arithmetic

/// A proxy protocol that mirrors Numeric while maintaining Tagged type safety
///
/// This protocol extends TaggedAdditiveArithmetic to include multiplication and integer conversion,
/// similar to the standard library's Numeric protocol. It maintains type safety while allowing
/// common numeric operations.
public protocol TaggedNumericArithmetic: TaggedAdditiveArithmetic {
    /// Creates a new instance from a binary integer, if possible
    init?<T>(exactly source: T)
    where T: BinaryInteger

    /// Multiplies two values of this type
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

/// Implementation of TaggedNumericArithmetic for Tagged types where the raw value is Numeric
extension Tagged: TaggedNumericArithmetic
where TagRawValue: Numeric {
    @inlinable
    public init?<T>(exactly source: T)
    where T: BinaryInteger {
        guard let value = TagRawValue(exactly: source) else { return nil }
        self.init(value)
    }

    @inlinable
    public static func multiply(
        _ lhs: Tagged<TypeTag, TagRawValue>,
        _ rhs: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(lhs.rawValue * rhs.rawValue)
    }
}

// MARK: - Proxy Protocol for Signed Numeric

/// A proxy protocol that mirrors SignedNumeric while maintaining Tagged type safety
///
/// This protocol extends TaggedNumericArithmetic to include negation operations,
/// similar to the standard library's SignedNumeric protocol.
public protocol TaggedSignedNumeric: TaggedNumericArithmetic {
    /// Negates a value of this type
    /// - Parameter operand: The value to negate
    /// - Returns: The negated value
    @inlinable
    static func negate(_ operand: Self) -> Self
}

/// Implementation of TaggedSignedNumeric for Tagged types where the raw value is SignedNumeric
extension Tagged: TaggedSignedNumeric
where TagRawValue: SignedNumeric {
    @inlinable
    public static func negate(
        _ operand: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(-operand.rawValue)
    }
}

// MARK: - Proxy Protocol for Floating Point Operations

/// A proxy protocol that provides floating-point operations while maintaining Tagged type safety
///
/// This protocol provides common floating-point operations and properties while ensuring
/// type safety is maintained. It serves as a safe way to work with Tagged floating-point values.
public protocol TaggedFloatingPointOperations {
    /// The underlying floating-point type
    associatedtype Underlying

    /// Whether this value is normal
    @inlinable
    var isNormal: Bool { get }

    /// Whether this value is finite
    @inlinable
    var isFinite: Bool { get }

    /// Whether this value is zero
    @inlinable
    var isZero: Bool { get }

    /// Whether this value is subnormal
    @inlinable
    var isSubnormal: Bool { get }

    /// Whether this value is infinite
    @inlinable
    var isInfinite: Bool { get }

    /// Whether this value is NaN (Not a Number)
    @inlinable
    var isNaN: Bool { get }

    /// Divides a value by another value
    @inlinable
    static func divide(
        _ lhs: Self,
        by rhs: Underlying
    ) -> Self

    /// Computes the remainder of dividing this value by another
    @inlinable
    func remainder(dividingBy other: Self) -> Self

    /// Computes the square root of this value
    @inlinable
    func squareRoot() -> Self

    /// Returns this value rounded to the nearest integer
    @inlinable
    func rounded() -> Self

    /// The next representable value in the positive direction
    @inlinable
    var nextUp: Self { get }
}

/// Implementation of TaggedFloatingPointOperations for Tagged types where the raw value is FloatingPoint
extension Tagged: TaggedFloatingPointOperations
where TagRawValue: FloatingPoint {
    public typealias Underlying = TagRawValue

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
        _ lhs: Tagged<TypeTag, TagRawValue>,
        by rhs: TagRawValue
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(lhs.rawValue / rhs)
    }

    @inlinable
    public func remainder(
        dividingBy other: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(rawValue.remainder(dividingBy: other.rawValue))
    }

    @inlinable
    public func squareRoot() -> Tagged<TypeTag, TagRawValue> {
        Tagged(rawValue.squareRoot())
    }

    @inlinable
    public func rounded() -> Tagged<TypeTag, TagRawValue> {
        Tagged(rawValue.rounded())
    }

    @inlinable
    public var nextUp: Tagged<TypeTag, TagRawValue> {
        Tagged(rawValue.nextUp)
    }
}

/// Extension to provide magnitude property for integer Tagged types
extension Tagged
where TagRawValue: BinaryInteger {
    /// The magnitude of this value
    @inlinable
    public var magnitude: TagRawValue.Magnitude {
        rawValue.magnitude
    }
}

/// Extension to provide magnitude property for floating-point Tagged types
extension Tagged
where TagRawValue: FloatingPoint {
    /// The magnitude of this value
    @inlinable
    public var magnitude: TagRawValue {
        rawValue.magnitude
    }
}

/// Extension to provide Strideable conformance for Tagged types with Strideable raw values
extension Tagged: Strideable
where TagRawValue: Strideable {
    @inlinable
    public func distance(
        to other: Tagged<TypeTag, TagRawValue>
    ) -> TagRawValue.Stride {
        rawValue.distance(to: other.rawValue)
    }

    @inlinable
    public func advanced(
        by stride: TagRawValue.Stride
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(rawValue.advanced(by: stride))
    }
}

/// Extension to provide absolute value for signed numeric Tagged types
extension Tagged
where TagRawValue: SignedNumeric & Comparable {
    /// Returns the absolute value of this value
    @inlinable
    public static func abs(_ value: Tagged) -> Tagged {
        Tagged(Swift.abs(value.rawValue))
    }
}

/// Extension to provide overflow arithmetic operations for fixed-width integer Tagged types
extension Tagged
where TagRawValue: FixedWidthInteger {
    @inlinable
    public static func add(
        _ lhs: Tagged<TypeTag, TagRawValue>,
        _ rhs: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(lhs.rawValue &+ rhs.rawValue)
    }

    @inlinable
    public static func subtract(
        _ lhs: Tagged<TypeTag, TagRawValue>,
        _ rhs: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(lhs.rawValue &- rhs.rawValue)
    }

    @inlinable
    public static func multiply(
        _ lhs: Tagged<TypeTag, TagRawValue>,
        _ rhs: Tagged<TypeTag, TagRawValue>
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(lhs.rawValue &* rhs.rawValue)
    }

    @inlinable
    public static func *= (
        lhs: inout Tagged<TypeTag, TagRawValue>,
        rhs: TagRawValue
    ) {
        lhs = Tagged(lhs.rawValue &* rhs)
    }

    @inlinable
    public static func += (
        lhs: inout Tagged<TypeTag, TagRawValue>,
        rhs: Tagged<TypeTag, TagRawValue>
    ) {
        lhs = Tagged(lhs.rawValue &+ rhs.rawValue)
    }

    @inlinable
    public static func -= (
        lhs: inout Tagged<TypeTag, TagRawValue>,
        rhs: Tagged<TypeTag, TagRawValue>
    ) {
        lhs = Tagged(lhs.rawValue &- rhs.rawValue)
    }

    @inlinable
    public static func random(in range: Range<Tagged>) -> Tagged {
        let lowerBound = range.lowerBound.rawValue
        let upperBound = range.upperBound.rawValue
        let random = TagRawValue.random(in: lowerBound..<upperBound)
        return Tagged(random)
    }

    @inlinable
    public static func random(in range: ClosedRange<Tagged>) -> Tagged {
        let lowerBound = range.lowerBound.rawValue
        let upperBound = range.upperBound.rawValue
        let random = TagRawValue.random(in: lowerBound...upperBound)
        return Tagged(random)
    }
}

// MARK: - Floating Point Division
extension Tagged where TagRawValue: BinaryFloatingPoint {
    @inlinable
    public static func / (
        lhs: Tagged<TypeTag, TagRawValue>,
        rhs: TagRawValue
    ) -> Tagged<TypeTag, TagRawValue> {
        Tagged(lhs.rawValue / rhs)
    }
}
