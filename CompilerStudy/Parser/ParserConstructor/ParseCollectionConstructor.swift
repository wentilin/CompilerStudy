//
//  ParseCollectionConstructor.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/9.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class ParseCollectionConstructor {
    static func produceFirstCollection(_ productions: [Production], terminals: [TerminalNode], nonterminals: [NonterminalNode]) -> FirstCollection {
        var fCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // terminate
        for t in terminals {
            fCollection[NodeWrapper.with(t)] = [NodeWrapper.with(t)]
        }
        
        // epsilon
        fCollection[NodeWrapper.epsilonWrapper] = [NodeWrapper.epsilonWrapper]
        
        // eof
        fCollection[NodeWrapper.eofWrapper] = [NodeWrapper.eofWrapper]
        
        // noterminate
        for t in nonterminals {
            fCollection[NodeWrapper.with(t)] = []
        }
        
        var hasChanged: Bool = true
        while hasChanged {
            hasChanged = false
            for production in productions {
                let rightNodes = production.right
                var rhs = fCollection[NodeWrapper.with(production.right[0])]!
                rhs.remove(NodeWrapper.epsilonWrapper)
                var i = 0
                if !rightNodes.contains(where: { (node) -> Bool in
                    return node.value == Epsilon.default.value
                }) {
                    while i < (production.right.count-1), fCollection[NodeWrapper.with(production.right[i])]!.contains(NodeWrapper.epsilonWrapper) {
                        
                        let next = fCollection[NodeWrapper.with(production.right[i+1])]!
                        rhs.formUnion(next)
                        rhs.remove(.epsilonWrapper)
                        i += 1
                    }
                }
                
                if i == production.right.count-1, fCollection[NodeWrapper.with(production.right[i])]!.contains(NodeWrapper.epsilonWrapper) {
                    rhs.insert(.epsilonWrapper)
                }
                
                
                let beforeCount = fCollection[NodeWrapper.with(production.left)]!.count
                fCollection[NodeWrapper.with(production.left)]!.formUnion(rhs)
                let afterCount = fCollection[NodeWrapper.with(production.left)]!.count
                hasChanged = hasChanged || (beforeCount != afterCount)
            }
        }
        
        let items = fCollection.map({ FirstItem(node: $0.key.node, items: Array($0.value).map({ $0.node })) })
        
        return .init(items)
    }
    
    static func produceFollowCollection(_ productions: [Production], terminals: [TerminalNode], nonterminals: [NonterminalNode], firstCollection: FirstCollection) -> FollowCollection {
        var followCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // set empty
        for item in nonterminals {
            followCollection[NodeWrapper.with(item)] = []
        }
        
        // start
        followCollection[.with(productions[0].left)] = [.eofWrapper]
        
        var hasChanged = true
        while hasChanged {
            hasChanged = false
            for production in productions {
                var trailer = followCollection[NodeWrapper.with(production.left)]!
                for i in 0..<production.right.count {
                    let j = production.right.count - 1 - i
                    let node = production.right[j]
                    let fisrtItem = Set<NodeWrapper>(firstCollection[node].map({ NodeWrapper.with($0) }))
                    if node.type == .nonterminal {
                        let beforeCount = followCollection[NodeWrapper.with(node)]!.count
                        followCollection[NodeWrapper.with(node)]!.formUnion(trailer)
                        let afterCount = followCollection[NodeWrapper.with(node)]!.count
                        
                        hasChanged = hasChanged || (beforeCount != afterCount)
                        
                        let containsEpsilon = firstCollection[node].contains{ $0.value == Epsilon.default.value }
                        if containsEpsilon {
                            trailer.formUnion(fisrtItem)
                            trailer.remove(.epsilonWrapper)
                        } else {
                            trailer = Set<NodeWrapper>(fisrtItem)
                        }
                    } else {
                        trailer = Set<NodeWrapper>(fisrtItem)
                    }
                }
            }
        }
        
        let items = followCollection.map({ FollowItem(node: $0.key.node as! NonterminalNode, items: Array($0.value).map({ $0.node })) })
        
        return .init(items)
    }
    
    static func produceEnchanceFisrtCollection(productions: [Production], firstCollection: FirstCollection, followCollection: FollowCollection) -> EnhanceFirstCollection {
        var fCollection: [Production: [Node]] = [:]
        
        for production in productions {
            let rightNodes = production.right
            var rhs = Set<NodeWrapper>(firstCollection[production.right[0]].map({ NodeWrapper.with($0)}))
            
            var i = 0
            if !rightNodes.contains(where: { (node) -> Bool in
                return node.value == Epsilon.default.value
            }) {
                while i < (production.right.count-1), firstCollection[production.right[i]].contains(where: { (node) -> Bool in
                    return node.value == Epsilon.default.value
                }) {
                    
                    let next = Set<NodeWrapper>(firstCollection[production.right[i+1]].map({ NodeWrapper.with($0)}))
                    rhs.formUnion(next)
                    rhs.remove(.epsilonWrapper)
                    i += 1
                }
                
                if i == production.right.count-1, firstCollection[production.right[i]].contains(where: { (node) -> Bool in
                    return node.value == Epsilon.default.value
                }) {
                    rhs.insert(.epsilonWrapper)
                }
            }
            
            if rhs.contains(where: { wrapper in
                wrapper.node.value == Epsilon.default.value
            }) {
                rhs.formUnion(Set<NodeWrapper>(followCollection[production.left].map({ NodeWrapper.with($0) })))
            }
            
            fCollection[production] = Array(rhs).map({ $0.node })
        }
        
        return .init(fCollection)
    }
}
