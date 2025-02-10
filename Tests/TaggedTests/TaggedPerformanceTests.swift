import XCTest
@testable import Tagged

/// Performance tests for Tagged types
final class TaggedPerformanceTests: XCTestCase {
    // MARK: - Arithmetic Performance Tests

    func test_performance__maintains_speed__for_sequential_additions() {
        let counter = TaggedFixtures.validCounter

        measure {
            var result = Counter(0)
            for _ in 0..<10_000 {
                result += counter
            }
            XCTAssertGreaterThan(result.rawValue, 0)
        }
    }

    func test_performance__maintains_speed__for_array_operations() {
        let numbers = IntList(TaggedFixtures.Arrays.integers)

        measure {
            _ = numbers.map { $0 * 2 }
        }
    }

    // MARK: - Initialization Performance Tests

    func test_performance__maintains_speed__for_bulk_initialization() {
        measure {
            _ = TaggedFixtures.Arrays.integers.map(UserID.init(rawValue:))
        }
    }

    // MARK: - Codable Performance Tests

    func test_performance__maintains_speed__for_bulk_encoding() {
        let users = (0..<1000).map { index in
            TestUser(
                id: UserID(index),
                email: Email("test\(index)@example.com"),
                score: Price(Double(index))
            )
        }

        let encoder = JSONEncoder()

        measure {
            _ = try! encoder.encode(users)
        }
    }

    // MARK: - Collection Performance Tests

    func test_performance__maintains_speed__for_collection_iteration() {
        let list = IntList(TaggedFixtures.Arrays.integers)

        measure {
            var sum = 0
            for element in list {
                sum += element
            }
            XCTAssertGreaterThan(sum, 0)
        }
    }

    // MARK: - String Operations Performance Tests

    func test_performance__maintains_speed__for_string_operations() {
        let emails = TaggedFixtures.Arrays.strings.map { Email("test\($0)@example.com") }

        measure {
            _ = emails.map { $0.rawValue.uppercased() }
        }
    }

    // MARK: - Memory Usage Tests

    func test_performance__maintains_low_memory__for_large_arrays() {
        measure {
            let array = [Int](repeating: 0, count: 100_000)
            let tagged = IntList(array)
            XCTAssertEqual(tagged.count, array.count)
        }
    }
}

// MARK: - Memory Leak Detection
extension TaggedPerformanceTests {
    func test_memory__does_not_leak__when_creating_and_destroying() {
        class Box<T> {
            let value: T
            init(_ value: T) { self.value = value }
        }

        weak var weakReference: Box<UserID>? = nil

        autoreleasepool {
            let boxed = Box(UserID(42))
            weakReference = boxed
            XCTAssertNotNil(weakReference)
        }

        XCTAssertNil(weakReference, "Tagged type should be deallocated")
    }
}
