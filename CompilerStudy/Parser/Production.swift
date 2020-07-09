//
//  Production.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/7.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class Production: NSObject {
    let left: NonterminalNode
    let right: [Node]
    let order: Int
    
    init(left: NonterminalNode, right: [Node], order: Int) {
        self.left = left
        self.right = right
        self.order = order
    }
    
    override var description: String {
        return self.left.value + " ->" + right.reduce("", { (res, node) -> String in
                     res + " " + node.value
                }) + "[\(order)]"
    }
}
