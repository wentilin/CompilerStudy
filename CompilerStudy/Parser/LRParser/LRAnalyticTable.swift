//
//  LRAnalyticTable.swift
//  CompilerStudy
//
//  Created by wentilin on 2020/7/11.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

enum LRAnalyticActionType: CustomStringConvertible {
    case shift(order: Int)
    case reduce(production: Production)
    case accept
    
    var description: String {
        switch self {
        case .shift(let order):
            return "shift \(order)"
        case .reduce(let order):
            return "reduce \(order)"
        case .accept:
            return "accept"
        }
    }
}

struct LRAnalyticActionKey: Hashable, CustomStringConvertible {
    let collectionOrder: Int
    let node: Node
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(collectionOrder)
        hasher.combine(node.value)
    }
    
    static func == (lhs: LRAnalyticActionKey, rhs: LRAnalyticActionKey) -> Bool {
        lhs.collectionOrder == rhs.collectionOrder && lhs.node.value == rhs.node.value
    }
    
    var description: String {
        return "ActionKey<\(collectionOrder), \(node.value)>"
    }
}

struct LRAnalyticGotoKey: Hashable, CustomStringConvertible {
    let collectionOrder: Int
    let node: NonterminalNode
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(collectionOrder)
        hasher.combine(node.value)
    }
    
    static func == (lhs: LRAnalyticGotoKey, rhs: LRAnalyticGotoKey) -> Bool {
        lhs.collectionOrder == rhs.collectionOrder && lhs.node.value == rhs.node.value
    }
    
    var description: String {
        return "<\(collectionOrder), \(node.value)>"
    }
}

struct LRAnalyticActionCollection: CustomStringConvertible {
    private var actions: [LRAnalyticActionKey: LRAnalyticActionType] = [:]
    
    subscript(collectionOrder: Int, node: Node) -> LRAnalyticActionType? {
        get {
            actions[.init(collectionOrder: collectionOrder, node: node)]
        } set {
            actions[.init(collectionOrder: collectionOrder, node: node)] = newValue
        }
    }
    
    var description: String {
        return "\(actions)"
    }
    
    public func map<T>(_ transform: (LRAnalyticActionKey, LRAnalyticActionType) throws -> T) rethrows -> [T] {
        return try actions.map(transform)
    }
}

struct LRAnalyticGotoCollection: CustomStringConvertible {
    private var gotos: [LRAnalyticGotoKey: Int] = [:]
    
    subscript(collectionOrder: Int, node: NonterminalNode) -> Int? {
        get {
            gotos[.init(collectionOrder: collectionOrder, node: node)]
        } set {
            gotos[.init(collectionOrder: collectionOrder, node: node)] = newValue
        }
    }
    
    var description: String {
        return "\(gotos)"
    }
}

struct LRAnalyticTable: CustomStringConvertible {
    var actionCollection: LRAnalyticActionCollection = .init()
    var gotos: LRAnalyticGotoCollection = .init()
    
    var description: String {
        return """
        LRAnalyticTable:
        actions: \(actionCollection) \n
            gotos: \(gotos)
        """
    }
}
