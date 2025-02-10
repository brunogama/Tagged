//
//  Tagged+Operators.swift
//  Tagged
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import Foundation

// MARK: - Additive Arithmetic Operators

/// Implements the addition operator (+) for Tagged types that conform to TaggedAdditiveArithmetic
/// This operator uses a proxy protocol to ensure type-safety and prevent accidental operations between different Tagged types
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side Tagged value
/// - Returns: A new Tagged value representing the sum
@inlinable
public func + <T: TaggedAdditiveArithmetic>(lhs: T, rhs: T) -> T {
    T.add(lhs, rhs)
}

/// Implements the subtraction operator (-) for Tagged types that conform to TaggedAdditiveArithmetic
/// Uses proxy protocol pattern to maintain type-safety while allowing arithmetic operations
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side Tagged value
/// - Returns: A new Tagged value representing the difference
@inlinable
public func - <T: TaggedAdditiveArithmetic>(lhs: T, rhs: T) -> T {
    T.subtract(lhs, rhs)
}

// MARK: - Numeric Arithmetic Operators

/// Implements the multiplication operator (*) for Tagged types that conform to TaggedNumericArithmetic
/// The proxy protocol ensures operations are only performed between Tagged values of the same type
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side Tagged value
/// - Returns: A new Tagged value representing the product
@inlinable
public func * <T: TaggedNumericArithmetic>(lhs: T, rhs: T) -> T {
    T.multiply(lhs, rhs)
}

/// Implements the multiplication-assignment operator (*=) for Tagged types
/// Modifies the left-hand operand in place with the product
/// - Parameters:
///   - lhs: Left-hand side Tagged value (modified in place)
///   - rhs: Right-hand side Tagged value
@inlinable
public func *= <T: TaggedNumericArithmetic>(lhs: inout T, rhs: T) {
    lhs = T.multiply(lhs, rhs)
}

// MARK: - Signed Numeric Operators

/// Implements the unary negation operator (-) for Tagged types that conform to TaggedSignedNumeric
/// - Parameter operand: The Tagged value to negate
/// - Returns: A new Tagged value representing the negation
@inlinable
public prefix func - <T: TaggedSignedNumeric>(operand: T) -> T {
    T.negate(operand)
}

// MARK: - Floating Point Operators

/// Implements the division operator (/) for Tagged types that conform to TaggedFloatingPointOperations
/// - Parameters:
///   - lhs: Left-hand side Tagged value
///   - rhs: Right-hand side underlying value
/// - Returns: A new Tagged value representing the quotient
@inlinable
public func / <T: TaggedFloatingPointOperations>(lhs: T, rhs: T.Underlying) -> T {
    T.divide(lhs, by: rhs)
}

// MARK: - Fixed Width Integer Operators

/// Implements overflow addition operator (&+) for Tagged types with FixedWidthInteger raw values
/// Performs wrapping addition that never traps on overflow
@inlinable
public func &+ <TypeTag, TagRawValue: FixedWidthInteger>(lhs: Tagged<TypeTag, TagRawValue>, rhs: Tagged<TypeTag, TagRawValue>) -> Tagged<TypeTag, TagRawValue> {
    Tagged<TypeTag, TagRawValue>.add(lhs, rhs)
}

/// Implements overflow subtraction operator (&-) for Tagged types with FixedWidthInteger raw values
/// Performs wrapping subtraction that never traps on overflow
@inlinable
public func &- <TypeTag, TagRawValue: FixedWidthInteger>(
    lhs: Tagged<TypeTag, TagRawValue>,
    rhs: Tagged<TypeTag, TagRawValue>
) -> Tagged<TypeTag, TagRawValue> {
    Tagged<TypeTag, TagRawValue>.subtract(lhs, rhs)
}

/// Implements overflow multiplication operator (&*) for Tagged types with FixedWidthInteger raw values
/// Performs wrapping multiplication that never traps on overflow
@inlinable
public func &* <TypeTag, TagRawValue: FixedWidthInteger>(
    lhs: Tagged<TypeTag, TagRawValue>,
    rhs: Tagged<TypeTag, TagRawValue>
) -> Tagged<TypeTag, TagRawValue> {
    Tagged<TypeTag, TagRawValue>.multiply(lhs, rhs)
}

// MARK: - Binary Floating Point Operators

/// Implements division operator (/) for Tagged types with BinaryFloatingPoint raw values
/// Allows division of a Tagged value by its raw value type
@inlinable
public func / <TypeTag, TagRawValue: BinaryFloatingPoint>(
    lhs: Tagged<TypeTag, TagRawValue>,
    rhs: TagRawValue
) -> Tagged<TypeTag, TagRawValue> {
    Tagged<TypeTag, TagRawValue>(lhs.rawValue / rhs)
} 
