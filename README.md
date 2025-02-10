# Tagged

A lightweight, zero-cost abstraction library for adding type safety to primitive types in Swift.

## Overview

Tagged is a type-safe wrapper that prevents the accidental mixing of values that share the same underlying type. It provides compile-time guarantees that values of different semantic meanings cannot be mistakenly used interchangeably, even when they share the same underlying type.

This approach helps catch logical errors at compile-time rather than runtime, leading to more robust and maintainable code without any performance overhead.

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/brunogama/Tagged.git", exact: "1.0.1")
]
```

## Basic Usage

```swift
// Define your type tags
enum UserIDTag {}
enum PostIDTag {}

// Create type-safe aliases
typealias UserID = Tagged<UserIDTag, Int>
typealias PostID = Tagged<PostIDTag, Int>

// Use them in your code
let userId = UserID(1)
let postId = PostID(1)

// This won't compile - type safety at work
// let wrongId: UserID = postId  // Compiler error
```

## Features

### Built-in Protocol Conformances

Tagged automatically inherits conformance from its raw value type for the following protocols:

- `Equatable`
- `Hashable`
- `Comparable`
- `Codable`
- `CustomStringConvertible`
- `CustomDebugStringConvertible`
- `LosslessStringConvertible`
- `Sendable` (when raw value is Sendable)
- `ExpressibleByIntegerLiteral` (when raw value supports it)
- `ExpressibleByStringLiteral` (when raw value supports it)
- `ExpressibleByFloatLiteral` (when raw value supports it)
- `ExpressibleByBooleanLiteral` (when raw value supports it)
- `ExpressibleByUnicodeScalarLiteral` (when raw value supports it)
- `ExpressibleByExtendedGraphemeClusterLiteral` (when raw value supports it)
- `ExpressibleByArrayLiteral` (when raw value is array-like)
- `ExpressibleByDictionaryLiteral` (when raw value is dictionary-like)
- `ExpressibleByNilLiteral` (for Optional Tagged types)

### Collection Support

Full support for Swift's collection protocols when the raw value is a collection:

- `Sequence`
- `Collection`
- `BidirectionalCollection`
- `RandomAccessCollection`
- `MutableCollection`
- `RangeReplaceableCollection`

### Numeric Operations

Comprehensive support for numeric operations through type-safe protocols:

- `TaggedAdditiveArithmetic` (provides +, -)
- `TaggedNumericArithmetic` (provides _, _=)
- `TaggedSignedNumeric` (provides unary -)
- `TaggedFloatingPointOperations` (provides /, remainder, squareRoot, etc.)
- Fixed-width integer operations (&+, &-, &\*)
- Binary floating-point division
- Support for Strideable
- Random number generation for integer types
- Absolute value for signed numeric types
- Magnitude property for integer and floating-point types

### Optional Support

Built-in support for optional Tagged types with familiar Swift optional syntax:

```swift
enum UserIDTag {}
typealias OptionalUserID = Tagged<UserIDTag, Int?>

// Initialize as nil
let id1: OptionalUserID = nil

// Initialize with a value
let id2 = OptionalUserID(wrapped: 123)

// Access wrapped value
if let value = id2.wrapped {
    print(value) // prints: 123
}
```

### Dynamic Member Lookup

Support for accessing underlying raw value properties directly:

```swift
enum UserTag {}
typealias User = Tagged<UserTag, String>

let name = User("John")
// Access String properties directly
let uppercase = name.uppercased() // "JOHN"
let length = name.count // 4
```

## Example Use Cases

```swift
// Type-safe currency handling
enum USDTag {}
enum EURTag {}
typealias USD = Tagged<USDTag, Decimal>
typealias EUR = Tagged<EURTag, Decimal>

// Type-safe identifiers
enum OrderIDTag {}
typealias OrderID = Tagged<OrderIDTag, UUID>

// Dictionary usage
var orders: [OrderID: Order] = [:]
let orderId = OrderID(UUID())
orders[orderId] = Order()

// Collection usage
enum ListTag {}
typealias SafeList = Tagged<ListTag, [Int]>
let numbers = SafeList([1, 2, 3, 4, 5])
for number in numbers {
    print(number)
}
```

## Documentation

For a comprehensive guide on using Tagged types, including detailed examples and best practices, see our [Tagged Types Guide](tagged-types-guide.md).

## Requirements

- Swift 5.9+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## Contribution

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Tagged is available under the MIT license. See the LICENSE file for more info.

## Credits

Tagged was inspired by and builds upon the excellent [Tagged](https://github.com/pointfreeco/swift-tagged) implementation by [Point-Free](https://www.pointfree.co). The original implementation demonstrated the power of type-safe wrappers in Swift and has been instrumental in promoting better type safety practices in the Swift community.

## Support

If you have any questions or need help, please file an issue on the GitHub repository.
