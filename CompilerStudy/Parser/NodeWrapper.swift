//
//  NodeWrapper.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/6.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

struct NodeWrapper: Hashable, CustomStringConvertible {
    let node: Node
    private static var _cache: [String: NodeWrapper] = [:]
    
    static var epsilonWrapper: NodeWrapper = .init(Epsilon.default)
    
    static var eofWrapper: NodeWrapper = .init(EOFNode.default)
    
    private init(_ node: Node) {
        self.node = node
    }
    
    static func with(_ node: Node) -> NodeWrapper {
        if let wrapper = _cache[node.value] {
            return wrapper
        }
        
        let wrapper = NodeWrapper(node)
        _cache[node.value] = wrapper
        
        return wrapper
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node.value)
    }
    
    static func == (lhs: NodeWrapper, rhs: NodeWrapper) -> Bool {
        return lhs.node.value == rhs.node.value
    }
    
    var description: String { return node.value }
}
