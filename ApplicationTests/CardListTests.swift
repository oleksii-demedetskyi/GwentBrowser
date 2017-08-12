import XCTest
@testable import Application
import API

class CardListTests: XCTestCase {
    
    func testStartLoading() {
        var state = State()
        XCTAssertFalse(state.isNextLoading)
        reduce(state: &state, event: .didStartNextLoading)
        XCTAssertTrue(state.isNextLoading)
        
        reduce(state: &state, event: .didStartNextLoading)
        XCTAssertTrue(state.isNextLoading)
    }
    
    func testEndLoading() {
        var state = State()
        XCTAssertFalse(state.isNextLoading)
        reduce(state: &state, event: .didEndNextLoading)
        XCTAssertFalse(state.isNextLoading)
        
        state = State(cards: [], nextBatch: nil, isNextLoading: true)
        reduce(state: &state, event: .didEndNextLoading)
        XCTAssertFalse(state.isNextLoading)
    }
    
    func testDidLoadNextBatch() {
        var state = State(cards: [], nextBatch: nil, isNextLoading: true)
        
        reduce(state: &state, event: .didLoadNextBatch(cards))
        XCTAssertEqual(state.cards, cards.results)
        XCTAssertEqual(state.nextBatch, cards.next)
        
        // Test for append.
        reduce(state: &state, event: .didLoadNextBatch(cards))
        XCTAssertEqual(state.cards, cards.results + cards.results)
        XCTAssertEqual(state.nextBatch, cards.next)
        
    }
}
