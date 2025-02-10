//
//  Tagged+Primitives.swift
//  Tagged
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import Foundation

/// Extension to provide literal expression support for Tagged types.
///
/// This file provides conformance to various ExpressibleBy*Literal protocols, allowing Tagged types
/// to be initialized directly from literals when their raw value type supports it. This makes Tagged types
/// as convenient to use as their underlying types while maintaining type safety.
///
/// Example usage:
/// ```swift
/// enum UserIDTag {}
/// typealias UserID = Tagged<UserIDTag, Int>
///
/// // Can be initialized directly from an integer literal
/// let id: UserID = 123
///
/// enum NameTag {}
/// typealias Name = Tagged<NameTag, String>
///
/// // Can be initialized directly from a string literal
/// let name: Name = "John"
/// ```

/// Allows Tagged types to be initialized from integer literals
extension Tagged: ExpressibleByIntegerLiteral
where TagRawValue: ExpressibleByIntegerLiteral {
    /// Creates a new instance from an integer literal
    /// - Parameter value: The integer literal value
    @inlinable
    public init(integerLiteral value: TagRawValue.IntegerLiteralType) {
        self.init(TagRawValue(integerLiteral: value))
    }
}

/// Allows Tagged types to be initialized from string literals
extension Tagged: ExpressibleByStringLiteral
where TagRawValue: ExpressibleByStringLiteral {
    /// Creates a new instance from a string literal
    /// - Parameter value: The string literal value
    @inlinable
    public init(stringLiteral value: TagRawValue.StringLiteralType) {
        self.init(TagRawValue(stringLiteral: value))
    }
}

/// Allows Tagged types to be initialized from floating-point literals
extension Tagged: ExpressibleByFloatLiteral
where TagRawValue: ExpressibleByFloatLiteral {
    /// Creates a new instance from a floating-point literal
    /// - Parameter value: The floating-point literal value
    @inlinable
    public init(floatLiteral value: TagRawValue.FloatLiteralType) {
        self.init(TagRawValue(floatLiteral: value))
    }
}

/// Allows Tagged types to be initialized from boolean literals
extension Tagged: ExpressibleByBooleanLiteral
where TagRawValue: ExpressibleByBooleanLiteral {
    /// Creates a new instance from a boolean literal
    /// - Parameter value: The boolean literal value
    @inlinable
    public init(booleanLiteral value: TagRawValue.BooleanLiteralType) {
        self.init(TagRawValue(booleanLiteral: value))
    }
}

/// Allows Tagged types to be initialized from Unicode scalar literals
extension Tagged: ExpressibleByUnicodeScalarLiteral
where TagRawValue: ExpressibleByUnicodeScalarLiteral {
    /// Creates a new instance from a Unicode scalar literal
    /// - Parameter value: The Unicode scalar literal value
    @inlinable
    public init(
        unicodeScalarLiteral value: TagRawValue.UnicodeScalarLiteralType
    ) {
        self.init(TagRawValue(unicodeScalarLiteral: value))
    }
}

/// Allows Tagged types to be initialized from extended grapheme cluster literals
extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral
where TagRawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    /// Creates a new instance from an extended grapheme cluster literal
    /// - Parameter value: The extended grapheme cluster literal value
    @inlinable
    public init(
        extendedGraphemeClusterLiteral value: TagRawValue.ExtendedGraphemeClusterLiteralType
    ) {
        self.init(TagRawValue(extendedGraphemeClusterLiteral: value))
    }
}

/// Extension to provide convenient initialization from binary integers
extension Tagged {
    /// Creates a new instance from any binary integer type
    /// - Parameter value: The binary integer value
    @inlinable
    public init<T: BinaryInteger>(_ value: T)
    where TagRawValue: BinaryInteger {
        self.init(TagRawValue(value))
    }

    /// Creates a new instance from a binary integer, if it can be represented exactly
    /// - Parameter value: The binary integer value
    /// - Returns: A new instance if the value can be represented exactly, nil otherwise
    @inlinable
    public init?<T: BinaryInteger>(
        exactly value: T
    )
    where TagRawValue: BinaryInteger {
        guard let exact = TagRawValue(exactly: value) else { return nil }
        self.init(exact)
    }
}
