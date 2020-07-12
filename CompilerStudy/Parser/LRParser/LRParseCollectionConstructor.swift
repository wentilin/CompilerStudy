//
//  LRParseCollectionConstructor.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/9.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class LRParseCollectionConstructor: ParseCollectionConstructor {
    static func produceClosure(productions: [Production], items: [LRConanicalItem], firstCollection: FirstCollection, order: Int) -> LRConanicalCollection {
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
        
        return .init(items: res.map({ $0 }), order: order)
    }
    
    static func produceGotoCollection(productions: [Production], conanicalCollection: LRConanicalCollection, transitionNode: Node, firstCollection: FirstCollection, order: Int) -> LRConanicalCollection {
        var moved: Set<LRConanicalItem> = []
        for item in conanicalCollection {
            if let node = item.stackNode, node.value == transitionNode.value {
                moved.insert(.init(production: item.production, predictNode: item.predictNode, stackPostion: item.stackPostion+1))
            }
        }
        
        return produceClosure(productions: productions, items: moved.map{ $0 }, firstCollection: firstCollection, order: order)
    }
    
    static func produceConanicalCollectionSet(productions: [Production], firstCollection: FirstCollection) -> (LRConanicalCollectionSet, LRConanicalGotoCollection) {
        let cc0 = produceClosure(productions: productions, items: [.init(production: productions[0], predictNode: EOFNode.default, stackPostion: 0)], firstCollection: firstCollection, order: 0)
        var ccSet: [(cc: LRConanicalCollection, marked: Bool)] = [(cc0, false)]
        var gotoCollection: LRConanicalGotoCollection = .init()
        var hasChanged = true
        var order: Int = 1
        while hasChanged {
            hasChanged = false
            let setCount = ccSet.count
            for i in 0..<setCount {
                if !ccSet[i].marked {
                    for item in ccSet[i].cc where item.stackPostion < item.production.right.count {
                        let transitionNode = item.production.right[item.stackPostion]
                        let temp = produceGotoCollection(productions: productions,
                        conanicalCollection: ccSet[i].cc,
                        transitionNode: transitionNode,
                        firstCollection: firstCollection, order: order)
                        
                        if !temp.isEmpty, !ccSet.contains(where: { (cc, _) -> Bool in
                            return cc == temp
                        }){
                            ccSet.append((temp, false))
                            hasChanged = true
                            
                            order += 1
                        }
                        
                        let key = LRConanicalGotoKey(collection: ccSet[i].cc, node: transitionNode)
                        if !temp.isEmpty, gotoCollection[key] == nil {
                            gotoCollection[key] = temp
                        }
                    }
                }
                
                
                
                ccSet[i].marked = true
            }
        }
        
        return (LRConanicalCollectionSet(conanicalCollections: ccSet.map{ $0.cc }), gotoCollection)
    }
    
    static func produceAnalyticTable(collectionSet: LRConanicalCollectionSet, gotoCollection: LRConanicalGotoCollection, nonterminals: [NonterminalNode]) -> LRAnalyticTable {
        var analyticTable = LRAnalyticTable()
        for cc in collectionSet {
            for item in cc {
                if let stackNode = item.stackNode,
                    let goto = gotoCollection[cc, stackNode] { // [A -> B•C, a], shift
                    analyticTable.actionCollection[cc.order, stackNode] = .shift(order: goto.order)
                } else if item.stackNode == nil { // [A -> B•, a], reduce
                    analyticTable.actionCollection[cc.order, item.predictNode] = .reduce(productionOrder: item.production.order)
                } else if item.production.order == 0,
                    item.predictNode.value == EOFNode.default.value { // accept
                    analyticTable.actionCollection[cc.order, EOFNode.default] = .accept
                }
            }
            
            for n in nonterminals {
                if let goto = gotoCollection[cc, n] {
                    analyticTable.gotos[cc.order, n] = goto.order
                }
            }
        }
        
        return analyticTable
    }
}
