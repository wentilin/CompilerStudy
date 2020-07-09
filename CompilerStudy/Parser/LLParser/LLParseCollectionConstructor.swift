//
//  LLParseCollectionConstructor.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/9.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class LLParseCollectionConstructor: ParseCollectionConstructor {
    static func produceAnalyticTable(productions: [Production], nonterminals: [NonterminalNode], enhanceFirstCollection: EnhanceFirstCollection) -> AnalyticTable {
        var table = AnalyticTable()
        
        for production in productions {
            for node in enhanceFirstCollection[production] {
                if node.type == .terminal {
                    table[production.left, node] = production
                }
            }
            
            if enhanceFirstCollection[production].contains(where: { $0.value == EOFNode.default.value}) {
                table[production.left, EOFNode.default] = production
            }
        }
        
        return table
    }
}
