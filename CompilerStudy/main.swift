//
//  main.swift
//  CompilerStudy
//
//  Created by wentilin on 2020/7/4.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

let text = "1 - (4 - 4 * 5)"
let lexer = Lexer(text)

print("-----------------LL(1)-----------------")
let llParser = ParserBuilder.buildLLParser(lexer: lexer)
print(llParser.firstCollection)
print(llParser.followCollection)
print(llParser.enhanceFirstCollection)
print(llParser.analyticTable)

print("Begin parse: \(text)")
do {
    let result = try llParser.parse()
    print("Parse result: \(result)")
} catch {
    print("Parse failed: \(error)")
}


print("-----------------LR(1)-----------------")

let lrParser = ParserBuilder.buildLRParser(lexer: lexer)

let cc0 = LRParseCollectionConstructor.produceClosure(productions: lrParser.productions, items: [.init(production: lrParser.productions[0], predictNode: EOFNode.default, stackPostion: 0)], firstCollection: lrParser.firstCollection)
print("CC0: \(cc0)")

let goto0 = LRParseCollectionConstructor.produceGotoCollection(productions: lrParser.productions, conanicalCollection: cc0, transitionNode: TerminalNode.leftParenthesis, firstCollection: lrParser.firstCollection)
print("GOTO<\(TerminalNode.leftParenthesis)>: \(goto0)")

