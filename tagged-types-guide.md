# Tagged Types: Type-Safe Wrappers for Better Swift Code

## Introduction

Tagged Types provide a powerful way to add type safety to your Swift code by preventing the accidental mixing of values that share the same underlying type. This guide will demonstrate how Tagged Types solve common developer pain points and show practical examples of their usage.

## The Problem: Type Safety with Primitive Types

Consider a typical e-commerce application where you deal with different types of IDs:

```swift
func fetchUser(id: Int) { ... }
func fetchProduct(id: Int) { ... }
func fetchOrder(id: Int) { ... }

// Later in the code...
let userId = 123
let productId = 456

// This compiles but is logically wrong!
fetchProduct(id: userId)  // Oops! Passed a user ID to a product function
```

This is a common source of bugs where we accidentally pass the wrong type of ID because they share the same underlying type (`Int`).

## The Solution: Tagged Types

Tagged Types solve this by creating distinct types at compile time:

```swift
// Define type tags
enum UserIDTag {}
enum ProductIDTag {}
enum OrderIDTag {}

// Create type-safe aliases
typealias UserID = Tagged<UserIDTag, Int>
typealias ProductID = Tagged<ProductIDTag, Int>
typealias OrderID = Tagged<OrderIDTag, Int>

// Updated functions
func fetchUser(id: UserID) { ... }
func fetchProduct(id: ProductID) { ... }
func fetchOrder(id: OrderID) { ... }

// Now this won't compile!
let userId = UserID(123)
fetchProduct(id: userId)  // ❌ Compiler error: Cannot convert UserID to ProductID
```

## Real-World Use Cases

### 1. Financial Calculations

Prevent mixing of different currencies:

```swift
enum USDTag {}
enum EURTag {}
typealias USD = Tagged<USDTag, Decimal>
typealias EUR = Tagged<EURTag, Decimal>

struct Product {
    let price: USD

    func applyDiscount(_ percentage: Double) -> USD {
        return USD(self.price.rawValue * (1 - percentage))
    }
}

// This won't compile - prevents currency confusion
let dollarPrice = USD(99.99)
let euroPrice = EUR(89.99)
let product = Product(price: euroPrice)  // ❌ Compiler error
```

### 2. User Input Validation

Distinguish between validated and unvalidated data:

```swift
enum ValidatedTag {}
enum UnvalidatedTag {}

typealias ValidatedEmail = Tagged<ValidatedTag, String>
typealias UnvalidatedEmail = Tagged<UnvalidatedTag, String>

struct UserService {
    // Only accepts validated emails
    func createUser(email: ValidatedEmail) { ... }

    // Validation function that converts unvalidated to validated
    func validate(_ email: UnvalidatedEmail) -> Result<ValidatedEmail, ValidationError> {
        guard email.rawValue.contains("@") else {
            return .failure(.invalidFormat)
        }
        return .success(ValidatedEmail(email.rawValue))
    }
}

// Usage
let userInput = UnvalidatedEmail("user@example.com")
let userService = UserService()

// Won't compile - must validate first
userService.createUser(email: userInput)  // ❌ Compiler error

// Correct usage
if case .success(let validatedEmail) = userService.validate(userInput) {
    userService.createUser(email: validatedEmail)  // ✅ Works!
}
```

### 3. URL Handling

Distinguish between different types of URLs:

```swift
enum APIEndpointTag {}
enum WebURLTag {}
typealias APIEndpoint = Tagged<APIEndpointTag, URL>
typealias WebURL = Tagged<WebURLTag, URL>

struct NetworkService {
    // Only accepts API endpoints
    func fetch(from endpoint: APIEndpoint) async throws -> Data { ... }

    // Only accepts web URLs
    func openInBrowser(_ url: WebURL) { ... }
}
```

### 4. Using Tagged Types as Dictionary Keys

Tagged Types can be used as dictionary keys when their raw value conforms to `Hashable`:

```swift
enum UserNameTag {}
typealias UserName = Tagged<UserNameTag, String>

// User preferences dictionary keyed by username
var userPreferences: [UserName: [String: Any]] = [:]

let username = UserName("john_doe")
userPreferences[username] = ["theme": "dark", "fontSize": 14]

// Type safety prevents using wrong key type
let rawUsername = "john_doe"
userPreferences[rawUsername] = [:]  // ❌ Compiler error
```

### 5. Generic Abstractions

Tagged Types work great with generics for creating type-safe abstractions:

```swift
// Generic ID type for any entity
protocol Identifiable {
    associatedtype IDTag
    var id: Tagged<IDTag, UUID> { get }
}

// Generic result page
struct Page<T, TagType> {
    let items: [T]
    let nextCursor: Tagged<TagType, String>?
    let totalCount: Int
}

// Generic repository
protocol Repository<T> {
    associatedtype T
    associatedtype IDTag

    func fetch(id: Tagged<IDTag, UUID>) async throws -> T
    func fetchAll(cursor: Tagged<IDTag, String>?) async throws -> Page<T, IDTag>
}
```

## Benefits of Tagged Types

1. **Compile-time Safety**: Prevents logical errors at compile time rather than runtime
2. **Zero Runtime Overhead**: Tagged Types are just wrappers with no performance impact
3. **Self-Documenting Code**: The type name itself documents the intended use
4. **Refactoring Safety**: The compiler helps catch all places that need updating when types change
5. **Protocol Conformance**: Tagged Types automatically inherit protocol conformances from their raw values

## Best Practices

1. Use descriptive names for your tag types that clearly indicate their purpose
2. Create typealiases for commonly used Tagged Types to improve readability
3. Consider making dedicated modules for your Tagged Types to ensure consistency across your codebase
4. Use Tagged Types for all primitive values that have specific semantic meaning
5. Combine Tagged Types with value types (structs) for more complex domain models

## Real-World Integration Example

Here's a complete example showing how Tagged Types can be used in a typical application:

```swift
// MARK: - Type Definitions
enum UserIDTag {}
enum SessionTokenTag {}
enum APIKeyTag {}

typealias UserID = Tagged<UserIDTag, UUID>
typealias SessionToken = Tagged<SessionTokenTag, String>
typealias APIKey = Tagged<APIKeyTag, String>

// MARK: - Models
struct User: Identifiable, Codable {
    let id: UserID
    let email: ValidatedEmail
    let createdAt: Date
}

// MARK: - Services
class AuthenticationService {
    private var sessions: [UserID: SessionToken] = [:]

    func login(email: ValidatedEmail, password: String) async throws -> SessionToken {
        // Authentication logic...
        let token = SessionToken(UUID().uuidString)
        let userId = UserID(UUID())
        sessions[userId] = token
        return token
    }

    func validate(token: SessionToken) -> Bool {
        sessions.values.contains(token)
    }
}

// MARK: - API Client
class APIClient {
    private let apiKey: APIKey

    init(apiKey: APIKey) {
        self.apiKey = apiKey
    }

    func fetchUser(id: UserID) async throws -> User {
        // API request logic...
    }
}

// MARK: - Usage
let authService = AuthenticationService()
let apiClient = APIClient(apiKey: APIKey("your-api-key"))

async {
    let email = UnvalidatedEmail("user@example.com")
    if case .success(let validatedEmail) = validate(email) {
        let token = try await authService.login(email: validatedEmail, password: "password")

        if authService.validate(token: token) {
            // Fetch user data...
        }
    }
}
```

## Conclusion

Tagged Types are a powerful tool for writing safer, more maintainable Swift code. They provide compile-time guarantees that prevent common programming mistakes while adding zero runtime overhead. By using Tagged Types consistently throughout your codebase, you can catch potential bugs early and make your code more self-documenting and easier to maintain.

Remember that the goal is to make invalid states unrepresentable at compile time. Tagged Types are one of the many tools in Swift that help achieve this goal, alongside enums, structs, and the type system in general.
