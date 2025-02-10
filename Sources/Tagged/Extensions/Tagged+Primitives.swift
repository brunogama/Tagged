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
///
/// enum FriendsTag {}
/// typealias Friends = Tagged<FriendsTag, [String]>
///
/// // Can be initialized directly from an array literal
/// let friends: Friends = ["Alice", "Bob"]
///
/// enum MetadataTag {}
/// typealias Metadata = Tagged<MetadataTag, [String: Any]>
///
/// // Can be initialized directly from a dictionary literal
/// let metadata: Metadata = ["age": 25, "city": "New York"]
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

/// A protocol that enables array literal initialization for types that can be constructed from arrays
///
/// This protocol is used internally to support array literal initialization for Tagged types
/// whose raw value is an array-like collection.
public protocol ArrayLiteralProxy {
    /// The type of elements in the array
    associatedtype Element
    
    /// Creates a new instance from an array of elements
    /// - Parameter elements: The array of elements to initialize with
    init(arrayLiteralElements elements: [Element])
}

/// Conformance of Array to ArrayLiteralProxy to enable array literal initialization
extension Array: ArrayLiteralProxy {
    @inlinable
    public init(arrayLiteralElements elements: [Element]) {
        self = [Element](elements)
    }
}

/// Allows Tagged types to be initialized from array literals when the raw value type is array-like
extension Tagged: ExpressibleByArrayLiteral
where TagRawValue: ArrayLiteralProxy {
    /// Creates a new instance from an array literal
    /// - Parameter elements: The array literal elements
    @inlinable
    public init(arrayLiteral elements: TagRawValue.Element...) {
        self.init(TagRawValue(arrayLiteralElements: elements))
    }
}

/// A protocol that enables dictionary literal initialization for types that can be constructed from key-value pairs
///
/// This protocol is used internally to support dictionary literal initialization for Tagged types
/// whose raw value is a dictionary-like collection.
public protocol DictionaryLiteralProxy {
    /// The type of keys in the dictionary
    associatedtype Key: Hashable
    /// The type of values in the dictionary
    associatedtype Value
    
    /// Creates a new instance from an array of key-value pairs
    /// - Parameter elements: The array of key-value pairs to initialize with
    init(dictionaryLiteralArray elements: [(Key, Value)])
}

/// Conformance of Dictionary to DictionaryLiteralProxy to enable dictionary literal initialization
extension Dictionary: DictionaryLiteralProxy {
    @inlinable
    public init(dictionaryLiteralArray elements: [(Key, Value)]) {
        self = Dictionary(uniqueKeysWithValues: elements)
    }
}

/// Allows Tagged types to be initialized from dictionary literals when the raw value type is dictionary-like
extension Tagged: ExpressibleByDictionaryLiteral
where RawValue: DictionaryLiteralProxy, RawValue.Key: Hashable {
    /// Creates a new instance from a dictionary literal
    /// - Parameter elements: The dictionary literal elements as key-value pairs
    @inlinable
    public init(dictionaryLiteral elements: (RawValue.Key, RawValue.Value)...) {
        self.init(RawValue(dictionaryLiteralArray: elements))
    }
}
