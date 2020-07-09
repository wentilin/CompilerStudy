//
//  LRParseCollectionConstructor.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/9.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Cocoa

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

struct LRConanicalCollection: Sequence {
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

class LRParseCollectionConstructor: ParseCollectionConstructor {
    static func produceClosure(items: [LRConanicalItem], firstCollection: FirstCollection) -> LRConanicalCollection {
        var hasChanged = true
        var res = Set<LRConanicalItem>(items)
        while hasChanged {
            let beforeCount = res.count
            var rhs = Set<LRConanicalItem>()
            for item in res {
                let nodes = item.production.right
                if item.stackPostion <= nodes.count - 1 {
                    if let nonterminalNode = nodes[item.stackPostion] as? NonterminalNode {
                        let firstCollection = ParseCollectionConstructor.produceFirstCollection(nodes: Array(nodes[item.stackPostion..<nodes.count] + [item.predictNode]), firstCollection: firstCollection)
                        for p in ParseRule.default.production(with: nonterminalNode) {
                            for node in firstCollection {
                                rhs.insert(.init(production: p, predictNode: node, stackPostion: 0))
                            }
                        }
                    }
                }
            }
            
            res.formUnion(rhs)
            let afterCount = res.count
            hasChanged = beforeCount != afterCount
            
        }
        
        return .init(items: res.map({ $0 }))
    }
    
    static func produceGotoCollection(with conanicalCollection: LRConanicalCollection, transitionNode: Node, firstCollection: FirstCollection) -> LRConanicalCollection {
        var moved: Set<LRConanicalItem> = []
        for item in conanicalCollection {
            if let node = item.stackNode, node.value == transitionNode.value {
                moved.insert(.init(production: item.production, predictNode: item.predictNode, stackPostion: item.stackPostion+1))
            }
        }
        
        return produceClosure(items: moved.map{ $0 }, firstCollection: firstCollection)
    }
}
