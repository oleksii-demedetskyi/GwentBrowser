//
//  SelectCardTests.swift
//  Card browserTests
//
//  Created by Alexey Demedetskii on 12/9/17.
//  Copyright © 2017 Alexey Demedeckiy. All rights reserved.
//


// dalog@me.com

import XCTest
@testable import Card_browser

class TestDispatcher: Dispatcher {
    var actions: [Action] = []
    func dispatch(action: Action) {
        actions.append(action)
    }
}

class SelectCardTests: XCTestCase {
    
    func test() {
        let cardLink = CardLink(
            href: URL(string: "http://some.url")!,
            name: "Card 1")
        
        let expectGetURL = expectation(description: "get url")
        
        let dispatcher = TestDispatcher()
        
        let command = selectCard(link: cardLink) { url, callback in
            XCTAssert(url == cardLink.href)
            XCTAssert((dispatcher.actions.last as! DidSelectCard).link == cardLink)
            
            expectGetURL.fulfill()
            callback(Card(name: "Card"))
        }
        
        command.perform(with: dispatcher)
        
        wait(for: [expectGetURL], timeout: 0)
        XCTAssert(dispatcher.actions.last is DidLoadCard)
        XCTAssert(dispatcher.actions.count == 2)
    }
}
