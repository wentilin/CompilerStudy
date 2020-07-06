//
//  FollowCollection.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/6.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

struct FollowItem {
    let node: NonterminalNode
    var items: [Node]
}

struct FollowCollection: CustomStringConvertible {
    private var items: [NodeWrapper: FollowItem] = [:]
    
    init(_ items: [FollowItem]) {
        for item in items {
            self.items[NodeWrapper.with(item.node)] = item
        }
    }
    
    subscript(node: Node) -> [Node] {
        return items[NodeWrapper.with(node)]?.items ?? []
    }
    
    var description: String {
        var des = "FollowCollection(\n"
        for item in items {
            des += "    \(item.key.node.value): \(item.value.items), \n"
        }
        
        des += ")"
        
        return des
    }
}
