//
//  Tagged+Optional.swift
//  Tagged
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import Foundation

/// Extension to provide optional type support for Tagged types.
///
/// This file provides a protocol-based approach to working with optional values in Tagged types.
/// It allows Tagged types to work seamlessly with optional values while maintaining type safety.
///
/// Example usage:
/// ```swift
/// enum UserIDTag {}
/// typealias OptionalUserID = Tagged<UserIDTag, Int?>
///
/// // Can be initialized as nil
/// let id1: OptionalUserID = nil
///
/// // Can be initialized with a value
/// let id2: OptionalUserID = OptionalUserID(wrapped: 123)
///
/// // Can access the wrapped value
/// if let value = id2.wrapped {
///     print(value) // prints: 123
/// }
/// ```

/// A protocol that defines the interface for optional-like types
///
/// This protocol allows us to work with optional values in a generic way,
/// making it possible to implement optional functionality for Tagged types
/// without losing type safety.
public protocol OptionalType {
    /// The type of the wrapped value
    associatedtype Wrapped
    
    /// Converts this optional-like type to a standard Swift Optional
    @inlinable
    var optional: Optional<Wrapped> { get }
    
    /// Returns an instance representing the absence of a value
    @inlinable
    static var none: Self { get }
    
    /// Creates an instance that wraps the given value
    /// - Parameter wrapped: The value to wrap
    @inlinable
    static func some(_ wrapped: Wrapped) -> Self
}

/// Implementation of OptionalType for Swift's Optional type
extension Optional: OptionalType {
    @inlinable
    public var optional: Optional<Wrapped> { self }
}

/// Extension to provide optional type functionality for Tagged types
extension Tagged
where TagRawValue: OptionalType {
    /// Returns an instance representing the absence of a value
    @inlinable
    public static var none: Self {
        .init(TagRawValue.none)
    }
    
    /// Creates a new instance wrapping the given value
    /// - Parameter value: The value to wrap
    @inlinable
    public init(wrapped value: TagRawValue.Wrapped) {
        self.init(TagRawValue.some(value))
    }
    
    /// The wrapped value, if present
    @inlinable
    public var wrapped: TagRawValue.Wrapped? {
        rawValue.optional
    }
}

/// Allows Tagged types with optional raw values to be initialized with nil
extension Tagged: ExpressibleByNilLiteral
where TagRawValue: OptionalType {
    /// Creates a new instance initialized with nil
    @inlinable
    public init(nilLiteral: ()) {
        self = .none
    }
}
