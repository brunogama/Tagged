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

extension Tagged: RawRepresentable {}

extension Tagged: CustomPlaygroundDisplayConvertible {
    @inlinable
    public var playgroundDescription: Any {
        String(describing: rawValue)
    }
}

extension Tagged: Error where RawValue: Error {}

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension Tagged: Identifiable where RawValue: Identifiable {
    @inlinable
    public var id: RawValue.ID {
        rawValue.id
    }
}

/// Allows Tagged types to be initialized from integer literals
extension Tagged: ExpressibleByIntegerLiteral
where RawValue: ExpressibleByIntegerLiteral {
    /// Creates a new instance from an integer literal
    /// - Parameter value: The integer literal value
    @inlinable
    public init(integerLiteral value: RawValue.IntegerLiteralType) {
        self.init(RawValue(integerLiteral: value))
    }
}

/// Allows Tagged types to be initialized from string literals
extension Tagged: ExpressibleByStringLiteral
where RawValue: ExpressibleByStringLiteral {
    /// Creates a new instance from a string literal
    /// - Parameter value: The string literal value
    @inlinable
    public init(stringLiteral value: RawValue.StringLiteralType) {
        self.init(RawValue(stringLiteral: value))
    }
}

/// Allows Tagged types to be initialized from floating-point literals
extension Tagged: ExpressibleByFloatLiteral
where RawValue: ExpressibleByFloatLiteral {
    /// Creates a new instance from a floating-point literal
    /// - Parameter value: The floating-point literal value
    @inlinable
    public init(floatLiteral value: RawValue.FloatLiteralType) {
        self.init(RawValue(floatLiteral: value))
    }
}

/// Allows Tagged types to be initialized from boolean literals
extension Tagged: ExpressibleByBooleanLiteral
where RawValue: ExpressibleByBooleanLiteral {
    /// Creates a new instance from a boolean literal
    /// - Parameter value: The boolean literal value
    @inlinable
    public init(booleanLiteral value: RawValue.BooleanLiteralType) {
        self.init(RawValue(booleanLiteral: value))
    }
}

/// Allows Tagged types to be initialized from Unicode scalar literals
extension Tagged: ExpressibleByUnicodeScalarLiteral
where RawValue: ExpressibleByUnicodeScalarLiteral {
    /// Creates a new instance from a Unicode scalar literal
    /// - Parameter value: The Unicode scalar literal value
    @inlinable
    public init(
        unicodeScalarLiteral value: RawValue.UnicodeScalarLiteralType
    ) {
        self.init(RawValue(unicodeScalarLiteral: value))
    }
}

/// Allows Tagged types to be initialized from extended grapheme cluster literals
extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral
where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    /// Creates a new instance from an extended grapheme cluster literal
    /// - Parameter value: The extended grapheme cluster literal value
    @inlinable
    public init(
        extendedGraphemeClusterLiteral value: RawValue
            .ExtendedGraphemeClusterLiteralType
    ) {
        self.init(RawValue(extendedGraphemeClusterLiteral: value))
    }
}

/// Extension to provide convenient initialization from binary integers
extension Tagged {
    /// Creates a new instance from any binary integer type
    /// - Parameter value: The binary integer value
    @inlinable
    public init<T: BinaryInteger>(_ value: T)
    where RawValue: BinaryInteger {
        self.init(RawValue(value))
    }

    /// Creates a new instance from a binary integer, if it can be represented exactly
    /// - Parameter value: The binary integer value
    /// - Returns: A new instance if the value can be represented exactly, nil otherwise
    @inlinable
    public init?<T: BinaryInteger>(
        exactly value: T
    )
    where RawValue: BinaryInteger {
        guard let exact = RawValue(exactly: value) else { return nil }
        self.init(exact)
    }
}

/// Allows Tagged types to be initialized from array literals using unsafeBitCast.
///
/// This extension assumes that the Tagged's RawValue is layout‑compatible with
/// an array literal initializer.
extension Tagged: ExpressibleByArrayLiteral where RawValue: ExpressibleByArrayLiteral {
    /// Creates a new instance from an array literal.
    /// - Parameter elements: The array literal elements.
    @inlinable
    public init(arrayLiteral elements: RawValue.ArrayLiteralElement...) {
        let f = unsafeBitCast(
            RawValue.init(arrayLiteral:) as ((RawValue.ArrayLiteralElement)...) -> RawValue,
            to: (([RawValue.ArrayLiteralElement]) -> RawValue).self
        )
        self.init(f(elements))
    }
}

/// Allows Tagged types to be initialized from dictionary literals using unsafeBitCast.
///
/// This extension assumes that the Tagged's RawValue is layout‑compatible with
/// a dictionary literal initializer.
extension Tagged: ExpressibleByDictionaryLiteral where RawValue: ExpressibleByDictionaryLiteral {
    /// Creates a new instance from a dictionary literal.
    /// - Parameter elements: The dictionary literal elements as key-value pairs.
    @inlinable
    public init(dictionaryLiteral elements: (RawValue.Key, RawValue.Value)...) {
        let f = unsafeBitCast(
            RawValue.init(dictionaryLiteral:) as ((RawValue.Key, RawValue.Value)...) -> RawValue,
            to: (([(RawValue.Key, RawValue.Value)]) -> RawValue).self
        )
        self.init(f(elements))
    }
}
