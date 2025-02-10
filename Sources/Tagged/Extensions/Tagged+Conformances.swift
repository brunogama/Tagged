// swiftlint:disable file_length
//
//  Tagged+Conformances.swift
//  Tagged
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

/// Extension to provide standard protocol conformances for Tagged types.
///
/// This file provides conformance to common Swift protocols for Tagged types when their raw values
/// conform to those protocols. This allows Tagged types to work seamlessly with Swift's standard
/// library features while maintaining type safety.
///
/// Example usage:
/// ```swift
/// enum UserIDTag {}
/// typealias UserID = Tagged<UserIDTag, Int>
///
/// let id1 = UserID(1)
/// let id2 = UserID(2)
///
/// // Equatable
/// print(id1 == id2) // false
///
/// // Comparable
/// print(id1 < id2)  // true
///
/// // Hashable (can be used in Sets and as Dictionary keys)
/// let idSet: Set = [id1, id2]
///
/// // CustomStringConvertible
/// print(id1) // prints: 1
///
/// // Codable
/// let encoded = try JSONEncoder().encode(id1)
/// let decoded = try JSONDecoder().decode(UserID.self, from: encoded)
/// ```

/// Provides Equatable conformance for Tagged types with Equatable raw values
extension Tagged: Equatable
where RawValue: Equatable {
    /// Returns a Boolean value indicating whether two values are equal
    /// - Parameters:
    ///   - lhs: A value to compare
    ///   - rhs: Another value to compare
    @inlinable
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

/// Provides Hashable conformance for Tagged types with Hashable raw values
extension Tagged: Hashable
where RawValue: Hashable {
    /// Hashes the essential components of this value by feeding them into the given hasher
    /// - Parameter hasher: The hasher to use when combining the components of this instance
    @inlinable
    public func hash(into hasher: inout Hasher) {
        rawValue.hash(into: &hasher)
    }
}

/// Provides Comparable conformance for Tagged types with Comparable raw values
extension Tagged: Comparable
where RawValue: Comparable {
    /// Returns a Boolean value indicating whether the value of the first argument is less than that of the second argument
    /// - Parameters:
    ///   - lhs: A value to compare
    ///   - rhs: Another value to compare
    @inlinable
    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Provides CustomStringConvertible conformance for Tagged types with CustomStringConvertible raw values
extension Tagged: CustomStringConvertible {
    /// A textual representation of this instance
    @inlinable
    public var description: String {
        String(describing: rawValue)
    }
}

/// Provides CustomDebugStringConvertible conformance for Tagged types with CustomDebugStringConvertible raw values
extension Tagged: CustomDebugStringConvertible
where RawValue: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging
    @inlinable
    public var debugDescription: String {
        rawValue.debugDescription
    }
}

/// Provides LosslessStringConvertible conformance for Tagged types with LosslessStringConvertible raw values
extension Tagged: LosslessStringConvertible
where RawValue: LosslessStringConvertible {
    /// Creates an instance from a string representation
    /// - Parameter description: A string to parse into a new instance
    /// - Returns: An instance containing the parsed value, or nil if parsing failed
    @inlinable
    public init?(_ description: String) {
        guard let value = RawValue(description) else { return nil }
        self.init(value)
    }
}

/// Provides Encodable conformance for Tagged types with Encodable raw values
extension Tagged: Encodable
where RawValue: Encodable {
    /// Encodes this value into the given encoder
    /// - Parameter encoder: The encoder to write data to
    /// - Throws: Any error that occurs during encoding
    @inlinable
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

/// Provides Decodable conformance for Tagged types with Decodable raw values
extension Tagged: Decodable
where RawValue: Decodable {
    /// Creates a new instance by decoding from the given decoder
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: Any error that occurs during decoding
    @inlinable
    public init(from decoder: Decoder) throws {
        let value = try RawValue(from: decoder)
        self.init(value)
    }
}

#if canImport(Foundation)
  import Foundation

  extension Tagged: LocalizedError where RawValue: Error {
    public var errorDescription: String? {
      rawValue.localizedDescription
    }

    public var failureReason: String? {
      (rawValue as? LocalizedError)?.failureReason
    }

    public var helpAnchor: String? {
      (rawValue as? LocalizedError)?.helpAnchor
    }

    public var recoverySuggestion: String? {
      (rawValue as? LocalizedError)?.recoverySuggestion
    }
  }
#endif
