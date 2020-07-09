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
    let terminals: [TerminalNode]
    
    /// Nonterminal collection
    let nonterminals: [NonterminalNode]
    
    /// Proction collection
    let productions: [Production]
    
    private init() {
        (terminals, nonterminals, productions) = ParseRuleBuilder.buildArithmeticGrammer()
    }
    
    func production(with node: NonterminalNode) -> [Production] {
        return productions.filter({ $0.left.value == node.value })
    }
}

class ParseRuleBuilder {
    static func buildArithmeticGrammer() -> ([TerminalNode], [NonterminalNode], [Production]) {
        let terminals: [TerminalNode] = [.plus, .minus, .divide, .multiply, .num, .name, .leftParenthesis, .rightParenthesis]
        
        let nonterminals: [NonterminalNode] = [.goal, .expr, .expr_, .term, .term_, .factor]
        
        let productions: [Production] = [
            Production(left: .goal, right: [NonterminalNode.expr], order: 0),
            Production(left: .expr, right: [NonterminalNode.term, NonterminalNode.expr_], order: 1),
            Production(left: .expr_, right: [TerminalNode.plus, NonterminalNode.term, NonterminalNode.expr_], order: 2),
            Production(left: .expr_, right: [TerminalNode.minus, NonterminalNode.term, NonterminalNode.expr_], order: 3),
            Production(left: .expr_, right: [Epsilon.default], order: 4),
            Production(left: .term, right: [NonterminalNode.factor, NonterminalNode.term_], order: 5),
            Production(left: .term_, right: [TerminalNode.divide, NonterminalNode.factor, NonterminalNode.term_], order: 6),
            Production(left: .term_, right: [TerminalNode.multiply, NonterminalNode.factor, NonterminalNode.term_], order: 7),
            Production(left: .term_, right: [Epsilon.default], order: 8),
            Production(left: .factor, right: [TerminalNode.leftParenthesis, NonterminalNode.expr, TerminalNode.rightParenthesis], order: 9),
            Production(left: .factor, right: [TerminalNode.num], order: 10),
            Production(left: .factor, right: [TerminalNode.name], order: 11),
        ]
        
        return (terminals, nonterminals, productions)
    }
    
    static func buildBracketGrammer() -> ([TerminalNode], [NonterminalNode], [Production]) {
        let terminals: [TerminalNode] = [.plus, .minus, .divide, .multiply, .num, .name, .leftParenthesis, .rightParenthesis]
        
        let nonterminals: [NonterminalNode] = [.goal, .expr, .expr_, .term, .term_, .factor]
        
        let productions: [Production] = [
            Production(left: .goal, right: [NonterminalNode.expr], order: 0),
            Production(left: .expr, right: [NonterminalNode.term, NonterminalNode.expr_], order: 1),
            Production(left: .expr_, right: [TerminalNode.plus, NonterminalNode.term, NonterminalNode.expr_], order: 2),
            Production(left: .expr_, right: [TerminalNode.minus, NonterminalNode.term, NonterminalNode.expr_], order: 3),
            Production(left: .expr_, right: [Epsilon.default], order: 4),
            Production(left: .term, right: [NonterminalNode.factor, NonterminalNode.term_], order: 5),
            Production(left: .term_, right: [TerminalNode.divide, NonterminalNode.factor, NonterminalNode.term_], order: 6),
            Production(left: .term_, right: [TerminalNode.multiply, NonterminalNode.factor, NonterminalNode.term_], order: 7),
            Production(left: .term_, right: [Epsilon.default], order: 8),
            Production(left: .factor, right: [TerminalNode.leftParenthesis, NonterminalNode.expr, TerminalNode.rightParenthesis], order: 9),
            Production(left: .factor, right: [TerminalNode.num], order: 10),
            Production(left: .factor, right: [TerminalNode.name], order: 11),
        ]
        
        return (terminals, nonterminals, productions)
    }
}
