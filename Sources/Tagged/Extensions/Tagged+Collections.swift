/// Extension to provide collection type support for Tagged types.
///
/// This file provides conformance to Swift's collection protocols for Tagged types whose raw values
/// are collections. This allows Tagged types to be used seamlessly with Swift's collection protocols
/// while maintaining type safety.
///
/// # Overview
/// The collections extension enables Tagged types to work with all of Swift's collection protocols
/// while maintaining type safety. This means you can wrap any collection type (Array, Set, Dictionary, etc.)
/// with Tagged and still use all the collection functionality you're familiar with.
///
/// # Features
/// - Full support for Swift's collection hierarchy:
///   - `Sequence`: Basic iteration and sequence operations
///   - `Collection`: Random access and subscripting
///   - `BidirectionalCollection`: Backward traversal
///   - `RandomAccessCollection`: Efficient random access
///   - `MutableCollection`: In-place modification
///   - `RangeReplaceableCollection`: Adding and removing elements
///
/// # Performance
/// All collection operations are marked as `@inlinable` for optimal performance.
/// The Tagged wrapper adds no runtime overhead to collection operations.
///
/// # Example Usage
/// ```swift
/// // Define a type-safe list of user IDs
/// enum UserIDListTag {}
/// typealias UserIDList = Tagged<UserIDListTag, [Int]>
///
/// // Create and use the list
/// var userIds = UserIDList([1, 2, 3, 4, 5])
///
/// // Use like a normal array
/// for id in userIds {
///     print(id)
/// }
///
/// // Use collection methods
/// let first = userIds.first // Optional(1)
/// let count = userIds.count // 5
/// let element = userIds[2]  // 3
///
/// // Modify the collection
/// userIds.append(6)
/// userIds.remove(at: 0)
///
/// // Use higher-order functions
/// let doubled = userIds.map { $0 * 2 }
/// let evenIds = userIds.filter { $0.isMultiple(of: 2) }
/// ```

// MARK: - Sequence Conformance

/// Provides Sequence conformance for Tagged types wrapping sequences.
///
/// This conformance enables Tagged types to be used in for-in loops and with sequence operations
/// like map, filter, and reduce. It's the foundation for all collection-based operations.
///
/// # Example
/// ```swift
/// enum ValidatedEmailsTag {}
/// typealias ValidatedEmails = Tagged<ValidatedEmailsTag, [String]>
///
/// let emails = ValidatedEmails(["user1@example.com", "user2@example.com"])
///
/// // Use sequence operations
/// let domains = emails.map { $0.split(separator: "@").last ?? "" }
/// let containsAdmin = emails.contains { $0.hasPrefix("admin@") }
/// ```
extension Tagged: Sequence
where RawValue: Sequence {
    /// The type of iterator that will iterate over the elements.
    ///
    /// The iterator type is identical to the underlying sequence's iterator,
    /// maintaining full compatibility with the wrapped collection.
    public typealias Iterator = RawValue.Iterator

    /// Creates an iterator that will iterate over the elements of this sequence.
    ///
    /// This method is called automatically when you use a Tagged sequence in a for-in loop
    /// or with sequence operations like map and filter.
    @inlinable
    public func makeIterator() -> RawValue.Iterator {
        rawValue.makeIterator()
    }
}

// MARK: - Collection Conformance

/// Provides Collection conformance for Tagged types wrapping collections.
///
/// This conformance enables Tagged types to be used with all Collection protocol methods
/// and properties. It provides indexed access to elements and the ability to traverse
/// the collection's contents.
///
/// # Features
/// - Indexed access with subscripting
/// - Properties like count, isEmpty, first, last
/// - Methods for index manipulation
/// - Support for collection algorithms
///
/// # Example
/// ```swift
/// enum OrderedItemsTag {}
/// typealias OrderedItems = Tagged<OrderedItemsTag, [String]>
///
/// let items = OrderedItems(["Item1", "Item2", "Item3"])
///
/// // Use collection features
/// print(items.count)        // 3
/// print(items.isEmpty)      // false
/// print(items.first ?? "") // "Item1"
/// print(items[1])          // "Item2"
///
/// // Use collection algorithms
/// let reversed = items.reversed()
/// let prefix = items.prefix(2)
/// ```
extension Tagged: Collection
where RawValue: Collection {
    /// The type that represents a position in the collection.
    ///
    /// This type is used for subscripting and traversing the collection.
    public typealias Index = RawValue.Index

    /// The type of elements in the collection.
    ///
    /// This is the type you'll work with when accessing elements.
    public typealias Element = RawValue.Element

    /// The position of the first element.
    ///
    /// For empty collections, startIndex equals endIndex.
    @inlinable
    public var startIndex: Index { rawValue.startIndex }

    /// The position one past the last element.
    ///
    /// This is not a valid element position; it's the position after the last element.
    @inlinable
    public var endIndex: Index { rawValue.endIndex }

    /// Accesses the element at the specified position.
    ///
    /// - Parameter position: A valid index of the collection.
    /// - Returns: The element at the specified index.
    /// - Precondition: The position must be a valid index of the collection that is not equal to endIndex.
    @inlinable
    public subscript(position: Index) -> Element {
        rawValue[position]
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter index: A valid index of the collection.
    /// - Returns: The next index in the collection.
    /// - Precondition: The index must be a valid index of the collection that is not equal to endIndex.
    @inlinable
    public func index(after index: Index) -> Index {
        rawValue.index(after: index)
    }
}

// MARK: - BidirectionalCollection Conformance

/// Provides BidirectionalCollection conformance for Tagged types wrapping bidirectional collections.
///
/// This conformance enables Tagged types to be traversed both forward and backward efficiently.
/// It's particularly useful for collections like Array and LinkedList where backward traversal
/// is a natural operation.
///
/// # Example
/// ```swift
/// let items = OrderedItems(["First", "Second", "Third"])
///
/// // Traverse backwards
/// for item in items.reversed() {
///     print(item) // Prints: Third, Second, First
/// }
///
/// // Access last elements efficiently
/// if let last = items.last {
///     print(last) // Prints: Third
/// }
/// ```
extension Tagged: BidirectionalCollection
where RawValue: BidirectionalCollection {
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter index: A valid index of the collection that is not equal to startIndex.
    /// - Returns: The previous index in the collection.
    /// - Complexity: O(1)
    @inlinable
    public func index(before index: Index) -> Index {
        rawValue.index(before: index)
    }
}

// MARK: - RandomAccessCollection Conformance

/// Provides RandomAccessCollection conformance for Tagged types wrapping random access collections.
///
/// This conformance enables Tagged types to provide efficient random access to their elements,
/// with constant-time complexity for index manipulation and subscripting operations. This is
/// particularly useful for collections like Array where random access is a fundamental operation.
///
/// # Example
/// ```swift
/// let items = OrderedItems(["A", "B", "C", "D", "E"])
///
/// // Efficient random access
/// let middle = items[items.count / 2] // "C"
/// let slice = items[1...3] // ["B", "C", "D"]
/// ```
extension Tagged: RandomAccessCollection
where RawValue: RandomAccessCollection {}

/// Provides MutableCollection conformance for Tagged types wrapping mutable collections.
///
/// This conformance enables in-place modification of collection elements through subscripting.
/// It maintains type safety while allowing efficient updates to collection elements.
///
/// # Example
/// ```swift
/// var items = OrderedItems(["Old", "Values"])
///
/// // Modify elements in place
/// items[0] = "New"
/// items[1] = "Content"
/// // Now contains: ["New", "Content"]
/// ```
extension Tagged: MutableCollection
where RawValue: MutableCollection {
    /// Sets the element at the specified position.
    ///
    /// - Parameters:
    ///   - position: A valid index of the collection.
    ///   - newElement: The new element to add to the collection.
    /// - Precondition: The position must be a valid index of the collection that is not equal to endIndex.
    @inlinable
    public subscript(position: RawValue.Index) -> RawValue.Element {
        get { rawValue[position] }
        set { rawValue[position] = newValue }
    }
}

/// Provides RangeReplaceableCollection conformance for Tagged types wrapping range-replaceable collections.
///
/// This conformance enables adding and removing elements from the collection. It provides
/// the full range of mutation operations available to collections like Array.
///
/// # Example
/// ```swift
/// var items = OrderedItems()
///
/// // Add elements
/// items.append("First")
/// items.append(contentsOf: ["Second", "Third"])
///
/// // Remove elements
/// items.removeFirst()
/// items.removeLast()
///
/// // Replace elements
/// items.replaceSubrange(0...0, with: ["New First"])
/// ```
extension Tagged: RangeReplaceableCollection
where RawValue: RangeReplaceableCollection {
    /// Creates a new, empty collection.
    ///
    /// This initializer enables creating empty collections that can be filled later.
    @inlinable
    public init() {
        self.init(RawValue())
    }

    /// Replaces the specified subrange of elements with the given collection.
    ///
    /// - Parameters:
    ///   - subrange: The subrange of the collection to replace.
    ///   - newElements: The new elements to add to the collection.
    /// - Complexity: O(n), where n is the length of the range being replaced plus
    ///   the length of the replacement elements.
    @inlinable
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<RawValue.Index>,
        with newElements: C
    ) where C.Element == Element {
        rawValue.replaceSubrange(subrange, with: newElements)
    }
}
