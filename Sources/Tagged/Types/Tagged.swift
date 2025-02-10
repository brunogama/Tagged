/// A type-safe wrapper that prevents mixing of values that share the same underlying type.
///
/// The `Tagged` type provides compile-time guarantees that values of different semantic meanings
/// cannot be accidentally mixed, even if they share the same underlying type. This is particularly
/// useful for primitive types like `Int` or `String` that might represent different concepts in your domain.
///
/// # Overview
/// Tagged types help prevent logical errors at compile-time by creating distinct types for values that
/// might share the same underlying representation but have different semantic meanings in your domain model.
///
/// # Thread Safety
/// Tagged types are thread-safe when the underlying `RawValue` type conforms to `Sendable`. This makes
/// them suitable for use in concurrent contexts without additional synchronization.
///
/// # Performance
/// Tagged types are zero-cost abstractions. They compile away to their underlying type with no runtime overhead,
/// making them suitable for performance-critical code.
///
/// # Example Usage
/// ```swift
/// // Define type tags
/// enum UserIDTag {}
/// enum PostIDTag {}
///
/// // Create type aliases for better readability
/// typealias UserID = Tagged<UserIDTag, Int>
/// typealias PostID = Tagged<PostIDTag, Int>
///
/// // Now these are different types at compile time
/// let userID = UserID(1)
/// let postID = PostID(1)
///
/// // This won't compile - type safety!
/// // let wrongID: UserID = postID
/// ```
///
/// - Note: The `@frozen` attribute ensures the ABI stability of this type.
///
/// - Parameters:
///   - TypeTag: A phantom type used to differentiate between different semantic meanings.
///   - TagRawValue: The underlying type that stores the actual value.
@frozen
@dynamicMemberLookup
public struct Tagged<Tag, RawValue> {
    /// The wrapped value of the underlying type.
    ///
    /// While this property provides direct access to the underlying value,
    /// it's recommended to maintain type safety by working with the Tagged type
    /// whenever possible.
    public var rawValue: RawValue

    /// Creates a new tagged value wrapping the provided raw value.
    ///
    /// - Parameter rawValue: The value to wrap
    /// - Note: This initializer is marked as `@inlinable` for performance optimization
    @inlinable
    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    /// Creates a new tagged value wrapping the provided raw value.
    ///
    /// This alternative initializer provides a more explicit way to create tagged values
    /// when the context might be ambiguous.
    ///
    /// - Parameter rawValue: The value to wrap
    /// - Note: This initializer is marked as `@inlinable` for performance optimization
    @inlinable
    public init(rawValue: RawValue) {
      self.rawValue = rawValue
    }

    /// Provides dynamic mutable access to members of the underlying raw value.
    ///
    /// This subscript enables direct access to properties and methods of the underlying type
    /// through dynamic member lookup, allowing for a more fluent API while maintaining type safety.
    ///
    /// Example:
    /// ```swift
    /// typealias TaggedString = Tagged<StringTag, String>
    /// let value = TaggedString("hello")
    /// let uppercase = value.uppercased() // Directly calls String.uppercased()
    /// ```
    ///
    /// - Parameter dynamicMember: The name of the member to access
    /// - Returns: A function that forwards the member access to the raw value
    @inlinable
    public subscript<T>(
        dynamicMember keyPath: WritableKeyPath<RawValue, T>
    ) -> T {
        get {
            rawValue[keyPath: keyPath]
        }
        set {
            rawValue[keyPath: keyPath] = newValue
        }
    }

    /// Transforms the wrapped value using the provided closure while maintaining type safety.
    ///
    /// This method allows you to transform the underlying value while preserving the type-safe
    /// wrapper. It's particularly useful for performing operations that need to work with the
    /// raw value but should maintain type safety in their result.
    ///
    /// Example:
    /// ```swift
    /// let userId = UserID(5)
    /// let doubledId = userId.map { $0 * 2 } // Still a UserID
    /// ```
    ///
    /// - Parameter transform: A closure that takes the raw value and returns a transformed value
    /// - Returns: A new Tagged value wrapping the transformed value
    /// - Throws: Rethrows any error thrown by the transform closure
    @inlinable
    public func map<NewValue>(
        _ transform: (RawValue) throws -> NewValue
    ) rethrows -> Tagged<RawValue, NewValue> {
        Tagged<RawValue, NewValue>(rawValue: try transform(rawValue))
    }

    /// Safely coerces the tagged value to use a different tag while preserving the raw value.
    ///
    /// This method allows you to change the semantic meaning of a tagged value when you're
    /// certain about the type safety implications. Use this method with caution as it
    /// bypasses the type safety guarantees that Tagged types provide.
    ///
    /// Example:
    /// ```swift
    /// let userId = UserID(1)
    /// let adminId = userId.coerced(to: AdminIDTag.self) // Now it's an AdminID
    /// ```
    ///
    /// - Parameter type: The new tag type to coerce to
    /// - Returns: A new Tagged value with the same raw value but a different tag
    /// - Warning: Use this method sparingly as it bypasses type safety
    @inlinable
    public func coerced<NewTag>(
        to type: NewTag.Type
    ) -> Tagged<NewTag, RawValue> {
        unsafeBitCast(self, to: Tagged<NewTag, RawValue>.self)
    }
}

/// Conformance to Sendable for thread-safety when the underlying type is Sendable.
///
/// This conformance ensures that Tagged values can be safely used across thread or actor boundaries
/// when the underlying RawValue type is itself Sendable. This is particularly important for
/// concurrent programming and actor isolation.
///
/// Example:
/// ```swift
/// enum UserIDTag {}
/// typealias UserID = Tagged<UserIDTag, Int> // Automatically Sendable because Int is Sendable
///
/// actor UserManager {
///     func process(id: UserID) { // Safe to pass across actor boundary
///         // ...
///     }
/// }
/// ```
extension Tagged: Sendable
where RawValue: Sendable {}
