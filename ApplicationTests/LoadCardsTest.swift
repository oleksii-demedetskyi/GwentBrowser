import XCTest
@testable import Application
import API

class FutureRequest<P, R> {
    let params: P
    let promise: (R) -> ()
    
    init(params: P, promise: @escaping (R) -> ()) {
        self.params = params
        self.promise = promise
    }
    
    func complete(with result: R) { promise(result) }
}

class LoadCardsTest: XCTestCase {
    
    var events = [] as [Event]
    var pendingRequest: FutureRequest<URL?, Result<GwentAPI.Response.Cards>>?
    
    var action: ActionWith<State>!
    
    override func setUp() {
        super.setUp()
        let dispatch = ActionWith<Event> { self.events.append($0) }
        let load = loadCards { url in
            return Future<Result<GwentAPI.Response.Cards>> {
                self.pendingRequest = FutureRequest(params: url, promise: $0)
            }
        }
        
        action = ActionWith { state in load(state, dispatch) }
    }
    
    override func tearDown() {
        events = []
        pendingRequest = nil
        action = nil
        super.tearDown()
    }
    
    let cards = GwentAPI.Response.Cards(
        count: 1,
        previous: URL(string: "http://prev.url")!,
        next: URL(string: "http://next.url")!,
        results: [GwentAPI.Response.CardLink(
            href: URL(string: "http://card.href")!,
            name: "Card")]
    )
    
    func testWithInitialState() {
        
        action.perform(State())
        
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        XCTAssertEqual(request.params, nil)
        XCTAssertEqual(events, [.didStartNextLoading])
        
        request.complete(with: Result.value(cards))
        
        XCTAssertEqual(events, [
            .didStartNextLoading,
            .didLoadNextBatch(cards),
            .didEndNextLoading
        ])
    }
    
    func testWhenAlreadyLoading() {
        action.perform(State(cards: [], nextBatch: nil, isNextLoading: true))
        XCTAssertNil(pendingRequest)
    }
    
    func testWhenNoNextBatchAvailable() {
        action.perform(State(cards: cards.results, nextBatch: nil, isNextLoading: false))
        XCTAssertNil(pendingRequest)
    }
    
    func testWithSomeCards() {
        action.perform(State(cards: cards.results, nextBatch: cards.next, isNextLoading: false))
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        XCTAssertEqual(request.params, cards.next)
    }
    
    func testWithError() {
        action.perform(State(cards: cards.results, nextBatch: cards.next, isNextLoading: false))
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        enum Error: Swift.Error { case some }
        request.complete(with: Result.error(Error.some))
        
        XCTAssertEqual(events, [.didStartNextLoading, .didEndNextLoading])
    }   
}
