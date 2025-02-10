//
//  TaggedCollectionTests.swift
//  TaggedTests
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import XCTest
@testable import Tagged

/// Tests for Collection protocol conformance of Tagged types
final class TaggedCollectionTests: XCTestCase {
    // MARK: - Type Definitions

    private enum ListTag {}
    private typealias TaggedList = Tagged<ListTag, [Int]>

    private enum StringListTag {}
    private typealias TaggedStringList = Tagged<StringListTag, [String]>

    // MARK: - Basic Collection Operations

    func test_collection__accesses_elements__with_valid_index() {
        let list = TaggedList([1, 2, 3])
        XCTAssertEqual(list[1], 2)
    }

    func test_collection__accesses_elements__with_first_index() {
        let list = TaggedList([1, 2, 3])
        XCTAssertEqual(list[list.startIndex], 1)
    }

    func test_collection__accesses_elements__with_last_index() {
        let list = TaggedList([1, 2, 3])
        let lastIndex = list.index(before: list.endIndex)
        XCTAssertEqual(list[lastIndex], 3)
    }

    // MARK: - Empty Collection Tests

    func test_collection__provides_correct_indices__when_empty() {
        let emptyList = TaggedList([])
        XCTAssertEqual(emptyList.startIndex, emptyList.endIndex)
    }

    func test_collection__has_zero_count__when_empty() {
        let emptyList = TaggedList([])
        XCTAssertEqual(emptyList.count, 0)
    }

    // MARK: - Iteration Tests

    func test_collection__iterates_all_elements__in_correct_order() {
        let list = TaggedList([1, 2, 3])
        var iteration = 1

        for element in list {
            XCTAssertEqual(element, iteration)
            iteration += 1
        }
    }

    // MARK: - Bidirectional Collection Tests

    // swiftlint:disable:next function_body_length
    func test_collection__iterates_backward__from_end_to_start() {
        let list = TaggedList([1, 2, 3])
        var iteration = 3
        var index = list.index(before: list.endIndex)

        while index >= list.startIndex {
            XCTAssertEqual(list[index], iteration)
            iteration -= 1
            if index > list.startIndex {
                index = list.index(before: index)
            } else {
                break
            }
        }
    }

    // MARK: - Unicode Support Tests

    func test_collection__handles_strings__with_unicode_scalars() {
        let list = TaggedStringList(["Hello", "🌍", "世界"])
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[1], "🌍")
    }

    // MARK: - Array Literal Tests
    
    func test_arrayLiteralInitialization__shouldCreateTaggedArray__whenGivenValidLiteral() {
        enum StringArrayTag {}
        typealias StringArray = Tagged<StringArrayTag, [String]>
        
        let array: StringArray = ["one", "two", "three"]
        
        XCTAssertEqual(array.rawValue, ["one", "two", "three"])
    }
    
    func test_arrayLiteralInitialization__shouldCreateEmptyTaggedArray__whenGivenEmptyLiteral() {
        enum IntArrayTag {}
        typealias IntArray = Tagged<IntArrayTag, [Int]>
        
        let array: IntArray = []
        
        XCTAssertTrue(array.rawValue.isEmpty)
    }
    
    func test_arrayLiteralInitialization__shouldMaintainTypeIdentity__withDifferentArrayTags() {
        enum Tag1 {}
        enum Tag2 {}
        typealias StringArray1 = Tagged<Tag1, [String]>
        typealias StringArray2 = Tagged<Tag2, [String]>
        
        let array1: StringArray1 = ["one", "two"]
        let array2: StringArray2 = ["one", "two"]
        
        // This should not compile:
        // let _: StringArray1 = array2
        
        XCTAssertEqual(array1.rawValue, array2.rawValue)
        XCTAssertNotEqual(ObjectIdentifier(StringArray1.self), ObjectIdentifier(StringArray2.self))
    }
    
    // MARK: - Dictionary Literal Tests
    
    func test_dictionaryLiteralInitialization__shouldCreateTaggedDictionary__whenGivenValidLiteral() {
        enum MetadataTag {}
        typealias Metadata = Tagged<MetadataTag, [String: Int]>
        
        let dict: Metadata = ["one": 1, "two": 2]
        
        XCTAssertEqual(dict.rawValue, ["one": 1, "two": 2])
    }
    
    func test_dictionaryLiteralInitialization__shouldCreateEmptyTaggedDictionary__whenGivenEmptyLiteral() {
        enum DictTag {}
        typealias Dict = Tagged<DictTag, [String: Double]>
        
        let dict: Dict = [:]
        
        XCTAssertTrue(dict.rawValue.isEmpty)
    }
    
    func test_dictionaryLiteralInitialization__shouldMaintainTypeIdentity__withDifferentDictionaryTags() {
        enum Tag1 {}
        enum Tag2 {}
        typealias Dict1 = Tagged<Tag1, [String: Int]>
        typealias Dict2 = Tagged<Tag2, [String: Int]>
        
        let dict1: Dict1 = ["key": 1]
        let dict2: Dict2 = ["key": 1]
        
        // This should not compile:
        // let _: Dict1 = dict2
        
        XCTAssertEqual(dict1.rawValue, dict2.rawValue)
        XCTAssertNotEqual(ObjectIdentifier(Dict1.self), ObjectIdentifier(Dict2.self))
    }
    
    func test_dictionaryLiteralInitialization__shouldSupportComplexValues() {
        enum ConfigTag {}
        typealias Config = Tagged<ConfigTag, [String: Any]>
        
        let config: Config = [
            "numbers": [1, 2, 3],
            "nested": ["key": "value"],
            "mixed": [1, "two", 3.0]
        ]
        
        XCTAssertEqual((config.rawValue["numbers"] as! [Int]).count, 3)
        XCTAssertEqual((config.rawValue["nested"] as! [String: String])["key"], "value")
        XCTAssertEqual((config.rawValue["mixed"] as! [Any]).count, 3)
    }
    
    // MARK: - Collection Operations Tests
    
    func test_arrayOperations__shouldPreserveTaggedType() {
        enum ArrayTag {}
        typealias TestArray = Tagged<ArrayTag, [Int]>
        
        var array: TestArray = [1, 2, 3]
        
        // Test append
        array.rawValue.append(4)
        XCTAssertEqual(array.rawValue, [1, 2, 3, 4])
        
        // Test map
        let mapped = array.rawValue.map { $0 * 2 }
        XCTAssertEqual(mapped, [2, 4, 6, 8])
        
        // Test filter
        let filtered = array.rawValue.filter { $0 % 2 == 0 }
        XCTAssertEqual(filtered, [2, 4])
    }
    
    func test_dictionaryOperations__shouldPreserveTaggedType() {
        enum DictTag {}
        typealias TestDict = Tagged<DictTag, [String: Int]>
        
        var dict: TestDict = ["one": 1, "two": 2]
        
        // Test update
        dict.rawValue["three"] = 3
        XCTAssertEqual(dict.rawValue["three"], 3)
        
        // Test remove
        dict.rawValue.removeValue(forKey: "one")
        XCTAssertNil(dict.rawValue["one"])
        
        // Test transform values
        let transformed = dict.rawValue.mapValues { $0 * 2 }
        XCTAssertEqual(transformed, ["two": 4, "three": 6])
    }
}
