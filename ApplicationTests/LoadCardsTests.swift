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

let cards = GwentAPI.Response.Cards(
    count: 1,
    previous: URL(string: "http://prev.url")!,
    next: URL(string: "http://next.url")!,
    results: [GwentAPI.Response.CardLink(
        href: URL(string: "http://card.href")!,
        name: "Card")]
)

class LoadCardsTests: XCTestCase {
    
    var events = [] as [Application.Event]
    var pendingRequest: FutureRequest<URL?, Result<GwentAPI.Response.Cards>>?
    
    var action: ActionWith<Application.State>!
    
    override func setUp() {
        super.setUp()
        let dispatch = ActionWith<Application.Event> { self.events.append($0) }
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
    
    func testWithInitialState() {
        
        action.perform(Application.State())
        
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        XCTAssertEqual(request.params, nil)
        XCTAssertEqual(events, [.cardList(.didStartNextLoading)])
        
        request.complete(with: Result.value(cards))
        
        XCTAssertEqual(events, [
            .cardList(.didStartNextLoading),
            .cardList(.didLoadNextBatch(cards)),
            .cardList(.didEndNextLoading)
        ])
    }
    
    func testWhenAlreadyLoading() {
        action.perform(Application.State(
            cardList: CardList.State(cards: [], nextBatch: nil, isNextLoading: true)))
        XCTAssertNil(pendingRequest)
    }
    
    func testWhenNoNextBatchAvailable() {
        action.perform(Application.State(cardList: CardList.State(cards: cards.results, nextBatch: nil, isNextLoading: false)))
        XCTAssertNil(pendingRequest)
    }
    
    func testWithSomeCards() {
        action.perform(Application.State(cardList: CardList.State(cards: cards.results, nextBatch: cards.next, isNextLoading: false)))
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        XCTAssertEqual(request.params, cards.next)
    }
    
    func testWithError() {
        action.perform(Application.State(cardList: CardList.State(cards: cards.results, nextBatch: cards.next, isNextLoading: false)))
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        enum Error: Swift.Error { case some }
        request.complete(with: Result.error(Error.some))
        
        XCTAssertEqual(events, [
            .cardList(.didStartNextLoading),
            .cardList(.didEndNextLoading)])
    }   
}
