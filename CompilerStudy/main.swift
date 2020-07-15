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

let _text = "a=1+(1+2)*2-4-(2/2)"
let _lexer = Lexer(_text)
let lrParser = ParserBuilder.buildLRParser(lexer: _lexer)
print("GOTOs\n:\(lrParser.gotoCollection)")
print("CollectionSet:\(lrParser.collectionSet)")
print("\(lrParser.analyticTable)")

print("Begin parse: \(_text)")
do {
    let result = try lrParser.parse()
    print("Parse result: \(result)")
} catch {
    print("Parse failed: \(error)")
}

