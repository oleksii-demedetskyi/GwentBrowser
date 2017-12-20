//
//  CardListViewControllerTests.swift
//  Card browserTests
//
//  Created by Alexey Demedetskii on 12/9/17.
//  Copyright © 2017 Alexey Demedeckiy. All rights reserved.
//

import XCTest
@testable import Card_browser

class CardListViewControllerTests: XCTestCase {
    
    func testFullList() {
        let someURL = URL(string: "http://some.url")!
        
        let state = State(
            cardList: CardListState.init(
                links: [.init(href: someURL, name: "Card 1"),
                        .init(href: someURL, name: "Card 2")],
                nextPageURL: nil),
            selectedCard: SelectedCardState.none)
        
        let dispatcher = TestDispatcher()
        
        let props = CardListViewController.Props.init(
            state: state , dispatcher: dispatcher)
        
        XCTAssert(props.cards.count == 2)
        XCTAssert(props.cards[0].name == "Card 1")
        XCTAssert(props.cards[1].name == "Card 2")
        XCTAssert(props.onLastCellDisplayed == nil)
    }
    
    func testWithMorePages() {
        let someURL = URL(string: "http://some.url")!
        
        let state = State(
            cardList: CardListState.init(
                links: [.init(href: someURL, name: "Card 1"),
                        .init(href: someURL, name: "Card 2")],
                nextPageURL: someURL),
            selectedCard: SelectedCardState.none)
        
        let dispatcher = TestDispatcher()
        
        let props = CardListViewController.Props.init(
            state: state , dispatcher: dispatcher)
        
        XCTAssert(props.cards.count == 2)
        XCTAssert(props.cards[0].name == "Card 1")
        XCTAssert(props.cards[1].name == "Card 2")
        XCTAssert(props.onLastCellDisplayed != nil)
    }
}
