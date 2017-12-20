//
//  CardListStateTests.swift
//  Card browserTests
//
//  Created by Alexey Demedetskii on 12/9/17.
//  Copyright © 2017 Alexey Demedeckiy. All rights reserved.
//

import XCTest
@testable import Card_browser

extension CardLink : Equatable {
    public static func == (left: CardLink, right: CardLink) -> Bool {
        return left.href == right.href && left.name == right.name
    }
}

class CardListStateTests: XCTestCase {
    
    func test() {
        let url = URL(string: "http://some.url")!
        
        var state = CardListState(
            links: [.init(href: url, name: "Card 1"),
                    .init(href: url, name: "Card 2")],
            nextPageURL: nil)
        
        let action = DidLoadCardLinks(response: .init(
            next: url,
            results: [.init(href: url, name: "Card 3"),
                      .init(href: url, name: "Card 4")]))
        
        state = reduce(state, with: action)
        
        XCTAssert(state.nextPageURL == url)
        XCTAssert(state.links == [.init(href: url, name: "Card 1"),
                                  .init(href: url, name: "Card 2"),
                                  .init(href: url, name: "Card 3"),
                                  .init(href: url, name: "Card 4")])
    }
    
}
