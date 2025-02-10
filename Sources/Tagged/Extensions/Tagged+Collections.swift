//
//  Tagged+Collections.swift
//  Tagged
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import Foundation

/// Extension to provide collection type support for Tagged types.
///
/// This file provides conformance to Swift's collection protocols for Tagged types whose raw values
/// are collections. This allows Tagged types to be used seamlessly with Swift's collection protocols
/// while maintaining type safety.
///
/// Example usage:
/// ```swift
/// enum ListTag {}
/// typealias SafeList = Tagged<ListTag, [Int]>
///
/// let list = SafeList([1, 2, 3, 4, 5])
///
/// // Can be used like a normal array
/// for number in list {
///     print(number)
/// }
///
/// // Can use collection methods
/// let first = list.first // Optional(1)
/// let count = list.count // 5
/// let element = list[2]  // 3
/// ```

// MARK: - Sequence Conformance

/// Provides Sequence conformance for Tagged types wrapping sequences
///
/// This allows Tagged types to be used in for-in loops and with sequence operations
/// like map, filter, and reduce.
extension Tagged: Sequence
where TagRawValue: Sequence {
    /// The type of iterator that will iterate over the elements
    public typealias Iterator = TagRawValue.Iterator

    /// Creates an iterator that will iterate over the elements of this sequence
    @inlinable
    public func makeIterator() -> TagRawValue.Iterator {
        rawValue.makeIterator()
    }
}

// MARK: - Collection Conformance

/// Provides Collection conformance for Tagged types wrapping collections
///
/// This allows Tagged types to be used with all Collection protocol methods
/// and properties, such as count, isEmpty, first, last, etc.
extension Tagged: Collection
where TagRawValue: Collection {
    /// The type that represents a position in the collection
    public typealias Index = TagRawValue.Index

    /// The type of elements in the collection
    public typealias Element = TagRawValue.Element

    /// The position of the first element
    @inlinable
    public var startIndex: Index { rawValue.startIndex }

    /// The position one past the last element
    @inlinable
    public var endIndex: Index { rawValue.endIndex }

    /// Accesses the element at the specified position
    /// - Parameter position: The position of the element to access
    /// - Returns: The element at the specified position
    @inlinable
    public subscript(position: Index) -> Element {
        rawValue[position]
    }

    /// Returns the position immediately after the given index
    /// - Parameter index: A valid index of the collection
    /// - Returns: The next index in the collection
    @inlinable
    public func index(after index: Index) -> Index {
        rawValue.index(after: index)
    }
}

// MARK: - BidirectionalCollection Conformance

/// Provides BidirectionalCollection conformance for Tagged types wrapping bidirectional collections
///
/// This allows Tagged types to be traversed both forward and backward efficiently.
extension Tagged: BidirectionalCollection
where TagRawValue: BidirectionalCollection {
    /// Returns the position immediately before the given index
    /// - Parameter index: A valid index of the collection
    /// - Returns: The previous index in the collection
    @inlinable
    public func index(before index: Index) -> Index {
        rawValue.index(before: index)
    }
}

// MARK: - RandomAccessCollection Conformance

/// Provides RandomAccessCollection conformance for Tagged types wrapping random access collections
///
/// This allows Tagged types to provide efficient random access to their elements,
/// with constant-time complexity for index manipulation and subscripting operations.
extension Tagged: RandomAccessCollection
where TagRawValue: RandomAccessCollection {}
