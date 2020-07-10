//
//  LRParseCollectionConstructor.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/9.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class LRParseCollectionConstructor: ParseCollectionConstructor {
    static func produceClosure(productions: [Production], items: [LRConanicalItem], firstCollection: FirstCollection) -> LRConanicalCollection {
        var hasChanged = true
        var res = Set<LRConanicalItem>(items)
        while hasChanged {
            let beforeCount = res.count
            var rhs = Set<LRConanicalItem>()
            for item in res {
                let nodes = item.production.right
                if item.stackPostion <= nodes.count - 1 {
                    if let nonterminalNode = nodes[item.stackPostion] as? NonterminalNode {
                        let _firstCollection = ParseCollectionConstructor.produceFirstCollection(nodes: Array(nodes[item.stackPostion+1..<nodes.count] + [item.predictNode]), firstCollection: firstCollection)
                        let _productions = productions.filter({ $0.left.value == nonterminalNode.value })
                        for p in _productions {
                            for node in _firstCollection {
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
    
    static func produceGotoCollection(productions: [Production], conanicalCollection: LRConanicalCollection, transitionNode: Node, firstCollection: FirstCollection) -> LRConanicalCollection {
        var moved: Set<LRConanicalItem> = []
        for item in conanicalCollection {
            if let node = item.stackNode, node.value == transitionNode.value {
                moved.insert(.init(production: item.production, predictNode: item.predictNode, stackPostion: item.stackPostion+1))
            }
        }
        
        return produceClosure(productions: productions, items: moved.map{ $0 }, firstCollection: firstCollection)
    }
}
