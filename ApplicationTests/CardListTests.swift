import XCTest
@testable import Application
import API

class CardListTests: XCTestCase {
    
    func testStartLoading() {
        var state = CardList.State()
        XCTAssertFalse(state.isNextLoading)
        CardList.reduce(state: &state, event: .didStartNextLoading)
        XCTAssertTrue(state.isNextLoading)
        
        CardList.reduce(state: &state, event: .didStartNextLoading)
        XCTAssertTrue(state.isNextLoading)
    }
    
    func testEndLoading() {
        var state = CardList.State()
        XCTAssertFalse(state.isNextLoading)
        CardList.reduce(state: &state, event: .didEndNextLoading)
        XCTAssertFalse(state.isNextLoading)
        
        state = CardList.State(cards: [], nextBatch: nil, isNextLoading: true)
        CardList.reduce(state: &state, event: .didEndNextLoading)
        XCTAssertFalse(state.isNextLoading)
    }
    
    func testDidLoadNextBatch() {
        var state = CardList.State(cards: [], nextBatch: nil, isNextLoading: true)
        
        CardList.reduce(state: &state, event: .didLoadNextBatch(cards))
        XCTAssertEqual(state.cards, cards.results)
        XCTAssertEqual(state.nextBatch, cards.next)
        
        // Test for append.
        CardList.reduce(state: &state, event: .didLoadNextBatch(cards))
        XCTAssertEqual(state.cards, cards.results + cards.results)
        XCTAssertEqual(state.nextBatch, cards.next)
    }
}
