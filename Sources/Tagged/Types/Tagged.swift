//
//  Tagged.swift
//  AppFoundation
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

/// A type-safe wrapper that prevents mixing of values that share the same underlying type.
///
/// The `Tagged` type provides compile-time guarantees that values of different semantic meanings
/// cannot be accidentally mixed, even if they share the same underlying type. This is particularly
/// useful for primitive types like `Int` or `String` that might represent different concepts in your domain.
///
/// Example usage:
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
    /// The wrapped value of the underlying type
    public var rawValue: RawValue

    /// Creates a new tagged value wrapping the provided raw value
    /// - Parameter rawValue: The value to wrap
    @inlinable
    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    @inlinable
    public init(rawValue: RawValue) {
      self.rawValue = rawValue
    }

    /// Provides dynamic mutable access to members of the underlying raw value
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

    @inlinable
    public func map<NewValue>(
        _ transform: (RawValue) throws -> NewValue
    ) rethrows -> Tagged<RawValue, NewValue> {
        Tagged<RawValue, NewValue>(rawValue: try transform(rawValue))
    }

    @inlinable
    public func coerced<NewTag>(
        to type: NewTag.Type
    ) -> Tagged<NewTag, RawValue> {
        unsafeBitCast(self, to: Tagged<NewTag, RawValue>.self)
    }
}

/// Conformance to Sendable for thread-safety when the underlying type is Sendable
extension Tagged: Sendable
where RawValue: Sendable {}
