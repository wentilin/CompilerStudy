//
//  ParserBuilder.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/8.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class ParserBuilder {
    static func buildLLParser(lexer: Lexer) -> LLParser {
        let (terminals, nonterminals, productions) = ParserBuilder.buildArithmeticGrammer()
        return .init(lexer: lexer, terminals: terminals, nonterminals: nonterminals, productions: productions)
    }
    
    static func buildLRParser(lexer: Lexer) -> LRParser {
        let (terminals, nonterminals, productions) = ParserBuilder.buildBracketGrammer()
        return .init(lexer: lexer, terminals: terminals, nonterminals: nonterminals, productions: productions)
    }
    
    private static func buildArithmeticGrammer() -> ([TerminalNode], [NonterminalNode], [Production]) {
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
    
    private static func buildBracketGrammer() -> ([TerminalNode], [NonterminalNode], [Production]) {
        let terminals: [TerminalNode] = [.leftParenthesis, .rightParenthesis]
        
        let nonterminals: [NonterminalNode] = [.goal, .list, .pair]
        
        let productions: [Production] = [
            Production(left: .goal, right: [NonterminalNode.list], order: 0),
            Production(left: .list, right: [NonterminalNode.list, NonterminalNode.pair], order: 1),
            Production(left: .list, right: [NonterminalNode.pair], order: 2),
            Production(left: .pair, right: [TerminalNode.leftParenthesis, NonterminalNode.pair, TerminalNode.rightParenthesis], order: 3),
            Production(left: .pair, right: [TerminalNode.leftParenthesis, TerminalNode.rightParenthesis], order: 4),
        ]
        
        return (terminals, nonterminals, productions)
    }
}
