//
//  NodeItem.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/6.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

struct FirstItem: CustomStringConvertible {
    let node: Node
    var items: [Node]
    
    var description: String {
        return "\(node.value): \(items)"
    }
}


struct FirstCollection: CustomStringConvertible {
    private var items: [NodeWrapper: FirstItem] = [:]
    
    init(_ items: [FirstItem]) {
        for item in items {
            self.items[NodeWrapper.with(item.node)] = item
        }
    }
    
    subscript(node: Node) -> [Node] {
        return items[NodeWrapper.with(node)]?.items ?? []
    }
    
    var description: String {
        var des = "FristCollection(\n"
        for item in items {
            des += "    \(item.key.node.value): \(item.value.items), \n"
        }
        
        des += ")"
        
        return des
    }
}

/// FIRST+(A -> β) = if ε ∉ FIRST(β) then FIRST(β) else FIRST(β) U FOLLOW(A)
struct EnhanceFirstCollection {
    private var items: [Production: [Node]] = [:]
    
    init(_ items: [Production: [Node]]) {
        self.items = items
    }
    
    subscript(production: Production) -> [Node] {
        return items[production] ?? []
    }
    
    var description: String {
        var des = "EnhanceFristCollection(\n"
        for item in items {
            des += "    \(item.key.left.value): \(item.value), \n"
        }
        
        des += ")"
        
        return des
    }
}
