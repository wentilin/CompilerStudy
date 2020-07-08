//
//  ParseRule.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/8.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class ParseRule {
    static let `default` = ParseRule()
    
    /// Terminal collection
    let terminals: [TerminalNode] = [.plus, .minus, .divide, .multiply, .num, .name, .leftParenthesis, .rightParenthesis]
    
    /// Nonterminal collection
    let nonterminals: [NonterminalNode] = [.expr, .expr_, .term, .term_, .factor]
    
    /// Proction collection
    let productions: [Production] = [
        Production(left: .expr, right: [NonterminalNode.term, NonterminalNode.expr_]),
        Production(left: .expr_, right: [TerminalNode.plus, NonterminalNode.term, NonterminalNode.expr_]),
        Production(left: .expr_, right: [TerminalNode.minus, NonterminalNode.term, NonterminalNode.expr_]),
        Production(left: .expr_, right: [Epsilon.default]),
        Production(left: .term, right: [NonterminalNode.factor, NonterminalNode.term_]),
        Production(left: .term_, right: [TerminalNode.divide, NonterminalNode.factor, NonterminalNode.term_]),
        Production(left: .term_, right: [TerminalNode.multiply, NonterminalNode.factor, NonterminalNode.term_]),
        Production(left: .term_, right: [Epsilon.default]),
        Production(left: .factor, right: [TerminalNode.leftParenthesis, NonterminalNode.expr, TerminalNode.rightParenthesis]),
        Production(left: .factor, right: [TerminalNode.num]),
        Production(left: .factor, right: [TerminalNode.name]),
    ]
}
