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

## Advanced Use Cases

### 1. Function Types and Transformers

Tagged Types can wrap function types, enabling type-safe transformations and function composition:

```swift
// Define transformation tags
enum Transform {}
enum Validation {}
enum Composition {}

// Basic transforms
typealias UserTransform = Tagged<Transform, (UserData) -> UserDataDTO>
typealias UserReverseTransform = Tagged<Transform, (UserDataDTO) -> UserData>
typealias PreferencesTransform = Tagged<Transform, (UserPreferences) -> UserPreferencesDTO>

// Validation functions
typealias EmailValidator = Tagged<Validation, (String) -> Bool>
typealias UserValidator = Tagged<Validation, (UserData) -> Bool>
```

### 2. Function Composition

Implement custom operators for composing transformations:

```swift
infix operator >>>>: ComparisonPrecedence

extension Tagged {
    static func >>>> <T, U, V>(
        lhs: Tagged<TypeTag, (T) -> U>,
        rhs: Tagged<TypeTag, (U) -> V>
    ) -> Tagged<TypeTag, (T) -> V> {
        Tagged { input in
            rhs.rawValue(lhs.rawValue(input))
        }
    }
}

// Usage example
extension UserTransform {
    static let enrichUser = Tagged<Transform, (UserData) -> UserData> { user in
        var enriched = user
        enriched.name = user.isVerified ? "\(user.name) ✓" : user.name
        return enriched
    }

    static let enrichedToDTO = enrichUser >>>> toDTO
}
```

### 3. Data Transformation Pipeline

Create type-safe transformation pipelines for your domain models:

```swift
struct UserData {
    let id: String
    let name: String
    let email: String
    let isVerified: Bool
    let joinDate: Date
}

struct UserDataDTO: Codable {
    let userId: String
    let displayName: String
    let emailAddress: String
    let verificationStatus: Bool
    let memberSince: TimeInterval
}

extension UserTransform {
    static let toDTO = UserTransform { user in
        UserDataDTO(
            userId: user.id,
            displayName: user.displayName,
            emailAddress: user.email,
            verificationStatus: user.isVerified,
            memberSince: user.joinDate.timeIntervalSince1970
        )
    }
}

extension UserReverseTransform {
    static let fromDTO = UserReverseTransform { dto in
        UserData(
            id: dto.userId,
            name: dto.displayName,
            email: dto.emailAddress,
            isVerified: dto.verificationStatus,
            joinDate: Date(timeIntervalSince1970: dto.memberSince)
        )
    }
}
```

### 4. Validation Rules

Build type-safe validation rules:

```swift
extension EmailValidator {
    static let isValid = EmailValidator { email in
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

extension UserValidator {
    static let isValid = UserValidator { user in
        EmailValidator.isValid.rawValue(user.email) &&
        !user.name.isEmpty &&
        user.name.count <= 50
    }

    static let canBeVerified = UserValidator { user in
        isValid.rawValue(user) && !user.isVerified
    }
}
```

### 5. Complete Service Layer Example

Integrate all concepts in a service layer:

```swift
final class UserService {
    func fetchUser() async throws -> TypeSafeResponse<TypeSafeUser> {
        let userData = UserData(
            id: "123",
            name: "John Doe",
            email: "john@example.com",
            isVerified: true,
            joinDate: Date()
        )

        // Transform to DTO
        let dto = UserTransform.toDTO.rawValue(userData)

        // Transform back to domain model with type safety
        let response = APIResponse(
            data: TypeSafeUser(UserReverseTransform.fromDTO.rawValue(dto)),
            metadata: APIMetadata(
                timestamp: Date(),
                version: "1.0",
                cacheControl: .init(isEnabled: true, ttl: 3600)
            ),
            status: APIStatus(code: 200, message: "Success")
        )

        return TypeSafeResponse(response)
    }

    func updateUser(_ user: TypeSafeUser) async throws -> TypeSafeResponse<TypeSafeUser> {
        guard UserValidator.isValid.rawValue(user.rawValue) else {
            throw NSError(domain: "UserValidation", code: 400)
        }

        // Use composed transformation
        let dto = UserTransform.enrichedToDTO.rawValue(user.rawValue)

        // Process and return response...
        return TypeSafeResponse(/* ... */)
    }
}
```

## Advanced Benefits

1. **Type-Safe Transformations**: Ensure data transformations maintain type safety throughout the pipeline
2. **Composable Functions**: Build complex transformations from simple, reusable pieces
3. **Validation Chain**: Create type-safe validation rules that can be composed and reused
4. **Clean Architecture**: Separate domain models from DTOs while maintaining type safety
5. **Functional Programming**: Leverage functional programming concepts with type safety

## Best Practices for Advanced Usage

1. **Compose Small Functions**: Build complex transformations by composing smaller, focused functions
2. **Type-Safe Validation**: Use Tagged Types for validation functions to ensure type safety
3. **Bidirectional Transforms**: Create pairs of transformations for domain ↔ DTO conversions
4. **Error Handling**: Use Result type with Tagged Types for better error handling
5. **Protocol Conformance**: Leverage protocol conformance for collections and numeric operations

## Conclusion

Tagged Types are a powerful tool for writing safer, more maintainable Swift code. They provide compile-time guarantees that prevent common programming mistakes while adding zero runtime overhead. By using Tagged Types consistently throughout your codebase, you can catch potential bugs early and make your code more self-documenting and easier to maintain.

Remember that the goal is to make invalid states unrepresentable at compile time. Tagged Types are one of the many tools in Swift that help achieve this goal, alongside enums, structs, and the type system in general.

Tagged Types can also go beyond of providing compile-time safety for simple type wrapping to provide a robust foundation for building type-safe transformations, validations, and complex data pipelines. By combining Tagged Types with functional programming concepts like function composition, you can create maintainable, type-safe code that catches errors at compile time rather than runtime.

The advanced patterns shown here demonstrate how Tagged Types can be used to build sophisticated systems while maintaining type safety throughout your application's architecture. Whether you're working with data transformations, validation rules, or complex business logic, Tagged Types provide the tools needed to write safer, more maintainable Swift code.
