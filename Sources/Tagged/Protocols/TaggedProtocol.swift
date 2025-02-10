//
//  TaggedProtocol.swift
//  AppFoundation
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

public protocol TaggedProtocol: RawRepresentable {
    associatedtype Tag
    associatedtype RawValue

    @inlinable
    init(_ value: RawValue)
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<RawValue, T>) -> T { get set }
}
