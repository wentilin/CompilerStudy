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
        if stackPostion <= production.right.count {
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
struct LRConanicalCollection: Sequence, Equatable {
    private var items: [LRConanicalItem]
    
    init(items: [LRConanicalItem]) {
        self.items = items
    }
    
    typealias Iterator  = AnyIterator<LRConanicalItem>
    
    func makeIterator() -> AnyIterator<LRConanicalItem> {
        var innerIterator = items.makeIterator()

        return AnyIterator { () -> LRConanicalItem? in
            return innerIterator.next()
        }
    }
}

extension LRConanicalCollection: CustomStringConvertible {
    var description: String {
        return "\(items.sorted{ $0.production.order < $1.production.order })"
    }
}

struct LRConanicalCollectionSet {
    var conanicalCollections: [LRConanicalCollection]
    
    func contains(_ conanicalCollection: LRConanicalCollection) -> Bool {
        return conanicalCollections.contains(where: { $0 == conanicalCollection })
    }
}

// MARK: -LRConanicalGotoItem
struct LRConanicalGotoItem {
    let node: Node
    let conanicalCollection: LRConanicalCollection
}
