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
    var dispatch: ActionWith<Event>!
    var pendingRequest: FutureRequest<URL?, Result<GwentAPI.Response.Cards>>?
    
    var action: ((State, ActionWith<Event>) -> ())!
    
    override func setUp() {
        super.setUp()
        dispatch = ActionWith<Event> { self.events.append($0) }
        action = loadCards { url in
            return Future<Result<GwentAPI.Response.Cards>> {
                self.pendingRequest = FutureRequest(params: url, promise: $0)
            }
        }
    }
    
    override func tearDown() {
        dispatch = nil
        events = []
        pendingRequest = nil
        action = nil
        super.tearDown()
    }
    
    func testWithInitialState() {
        
        action(State(), dispatch)
        
        guard let request = pendingRequest else { return XCTFail("No request was made")}
        XCTAssertEqual(request.params, nil)
        XCTAssertEqual(events, [.didStartNextLoading])
        
        let cards = GwentAPI.Response.Cards(
            count: 1,
            previous: URL(string: "http://prev.url")!,
            next: URL(string: "http://next.url")!,
            results: [GwentAPI.Response.CardLink(
                href: URL(string: "http://card.href")!,
                name: "Card")]
        )
        
        request.complete(with: Result.value(cards))
        
        XCTAssertEqual(events, [
            .didStartNextLoading,
            .didLoadNextBatch(cards),
            .didEndNextLoading
        ])
    }
}
