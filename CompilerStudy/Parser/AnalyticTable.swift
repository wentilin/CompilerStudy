//
//  AnalyticTable.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/7.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

struct AnalyticTable: CustomStringConvertible {
    private var table: [NonterminalNode: [NodeWrapper: Production]] = [:]
    
    subscript(nontermianl: NonterminalNode, node: Node) -> Production? {
        get {
            table[nontermianl]?[NodeWrapper.with(node)]
        }
        set {
            if table[nontermianl] == nil {
                table[nontermianl] = [:]
            }
            
            table[nontermianl]?[NodeWrapper.with(node)] = newValue
        }
    }
    
    var description: String {
        var str = "AnalyticTable(\n"
        
        for item in table {
            str += "    \(item.key.value): \(item.value)\n"
        }

        str += ")"
        
        return str
    }
}
