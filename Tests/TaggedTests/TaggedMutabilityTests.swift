import XCTest
@testable import Tagged

final class TaggedMutabilityTests: XCTestCase {
    // MARK: - Test Types

    private struct Person {
        var name: String
        var age: Int
    }

    private enum PersonTag {}
    private typealias TaggedPerson = Tagged<PersonTag, Person>

    // MARK: - Direct Mutation Tests

    func test_rawValue__canBeMutated__whenAssignedNewValue() {
        var tagged = TaggedPerson(Person(name: "John", age: 30))
        tagged.rawValue = Person(name: "Jane", age: 25)

        XCTAssertEqual(tagged.rawValue.name, "Jane")
        XCTAssertEqual(tagged.rawValue.age, 25)
    }

    func test_rawValue__canBeMutatedInPlace__whenModifyingProperties() {
        var tagged = TaggedPerson(Person(name: "John", age: 30))
        tagged.rawValue.name = "Jane"
        tagged.rawValue.age += 1

        XCTAssertEqual(tagged.rawValue.name, "Jane")
        XCTAssertEqual(tagged.rawValue.age, 31)
    }

    // MARK: - Dynamic Member Lookup Tests

    func test_dynamicMemberLookup__accessesProperties__throughKeyPath() {
        let tagged = TaggedPerson(Person(name: "John", age: 30))

        XCTAssertEqual(tagged.name, "John")
        XCTAssertEqual(tagged.age, 30)
    }

    func test_dynamicMemberLookup__mutatesProperties__throughKeyPath() {
        var tagged = TaggedPerson(Person(name: "John", age: 30))

        tagged.name = "Jane"
        tagged.age = 25

        XCTAssertEqual(tagged.name, "Jane")
        XCTAssertEqual(tagged.age, 25)
    }

    // MARK: - Collection Mutation Tests

    func test_arrayMutation__supportsInPlaceModification() {
        enum ListTag {}
        typealias IntList = Tagged<ListTag, [Int]>

        var list: IntList = [1, 2, 3]
        list.append(4)
        list[0] = 0

        XCTAssertEqual(Array(list), [0, 2, 3, 4])
    }

    func test_dictionaryMutation__supportsInPlaceModification() {
        enum DictTag {}
        typealias StringDict = Tagged<DictTag, [String: Int]>

        var dict: StringDict = ["one": 1]
        dict["two"] = 2
        dict["one"] = nil

        XCTAssertEqual(dict.rawValue, ["two": 2])
    }

    // MARK: - Type Safety Tests

    func test_mutation__maintainsTypeSafety__betweenDifferentTags() {
        enum Tag1 {}
        enum Tag2 {}
        typealias Person1 = Tagged<Tag1, Person>
        typealias Person2 = Tagged<Tag2, Person>

        var person1 = Person1(Person(name: "John", age: 30))
        var person2 = Person2(Person(name: "Jane", age: 25))

        person1.name = "Bob"
        person2.name = "Alice"

        // This should not compile:
        // person1 = person2

        XCTAssertEqual(person1.name, "Bob")
        XCTAssertEqual(person2.name, "Alice")
    }
}
