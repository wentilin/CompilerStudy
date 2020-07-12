//
//  LRConanicalCollection.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/10.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

// MARK: -LRConanicalItem
struct LRConanicalItem: Hashable, CustomStringConvertible {
    let production: Production
    let predictNode: Node
    let stackPostion: Int
    
    var stackNode: Node? {
        if stackPostion < production.right.count {
            return production.right[stackPostion]
        }
        
        return nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(production)
        hasher.combine(predictNode.value)
        hasher.combine(stackPostion)
    }
    
    static func == (lhs: LRConanicalItem, rhs: LRConanicalItem) -> Bool {
        return lhs.production == rhs.production &&
            lhs.predictNode.value == rhs.predictNode.value &&
            lhs.stackPostion == rhs.stackPostion
    }
    
    var description: String {
        var str = "<"
        str += production.left.value
        str += " -> "
        var nodes = production.right.map({ $0.value })
        nodes.insert("·", at: stackPostion)
        str += nodes.joined(separator: " ")
        str += "[\(production.order)]"
        str += ", \(predictNode.value)"
        str += ">"
        
        return str
    }
}

// MARK: -LRConanicalCollection
struct LRConanicalCollection: Sequence, Equatable, Hashable {
    private var items: Set<LRConanicalItem>
    
    var order: Int
    
    var count: Int { return items.count }
    
    var isEmpty: Bool { return items.isEmpty }
    
    init(items: [LRConanicalItem], order: Int) {
        self.items = Set<LRConanicalItem>(items)
        self.order = order
    }
    
    typealias Iterator  = AnyIterator<LRConanicalItem>
    
    func makeIterator() -> AnyIterator<LRConanicalItem> {
        var innerIterator = items.makeIterator()

        return AnyIterator { () -> LRConanicalItem? in
            return innerIterator.next()
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.items == rhs.items
    }
}

extension LRConanicalCollection: CustomStringConvertible {
    var description: String {
        return "<\(order)>\(items.sorted{ $0.production.order < $1.production.order })"
    }
}

// MARK: -LRConanicalCollectionSet
struct LRConanicalCollectionSet: Collection, CustomStringConvertible {
    private var conanicalCollections: [LRConanicalCollection]
    
    var startIndex: Int { return conanicalCollections.startIndex }
    
    var endIndex: Int { return conanicalCollections.startIndex }
    
    init(conanicalCollections: [LRConanicalCollection]) {
        self.conanicalCollections = conanicalCollections
    }
    
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    subscript(position: Int) -> LRConanicalCollection {
        return conanicalCollections[position]
    }
    
    func contains(_ conanicalCollection: LRConanicalCollection) -> Bool {
        return conanicalCollections.contains(where: { $0 == conanicalCollection })
    }
    
    func makeIterator() -> AnyIterator<LRConanicalCollection> {
        var innerIterator = conanicalCollections.makeIterator()

        return AnyIterator { () -> LRConanicalCollection? in
            return innerIterator.next()
        }
    }
    
    var description: String {
        return "\(conanicalCollections.map({ "\($0)" }).joined(separator: "\n"))"
    }
}



// MARK: -LRConanicalGotoItem
struct LRConanicalGotoKey: Hashable, CustomStringConvertible {
    let collection: LRConanicalCollection
    let node: Node

    func hash(into hasher: inout Hasher) {
        hasher.combine(collection)
        hasher.combine(node.value)
    }
    
    static func == (lhs: LRConanicalGotoKey, rhs: LRConanicalGotoKey) -> Bool {
        return lhs.collection == rhs.collection && lhs.node.value == rhs.node.value
    }
    
    var description: String {
        return "goto_key<\(collection.order), \(node.value)>"
    }
}

struct LRConanicalGotoCollection: Sequence, CustomStringConvertible {
    private var items: [LRConanicalGotoKey: LRConanicalCollection] = [:]
    
    subscript(gotoKey: LRConanicalGotoKey) -> LRConanicalCollection? {
        get {
            return items[gotoKey]
        } set {
            items[gotoKey] = newValue
        }
    }
    
    subscript(collectoin: LRConanicalCollection, node: Node) -> LRConanicalCollection? {
        get {
            return items[.init(collection: collectoin, node: node)]
        } set {
            items[.init(collection: collectoin, node: node)] = newValue
        }
    }
    
    func makeIterator() -> AnyIterator<(LRConanicalGotoKey, LRConanicalCollection)> {
        var innerIterator = items.makeIterator()

        return AnyIterator { () -> (LRConanicalGotoKey, LRConanicalCollection)? in
            return innerIterator.next()
        }
    }
    
    var description: String {
        let res = items.map({($0.key, $0.value)}).sorted(by: { $0.0.collection.order < $1.0.collection.order }).map({"\($0.0): \($0.1.order)"}).joined(separator: "\n")
        
        return "\(res)"
    }
}
