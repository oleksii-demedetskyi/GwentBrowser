import API

enum CardList {
    struct State {
        var cards = [] as [GwentAPI.Response.CardLink]
        var nextBatch = nil as URL?
        var isNextLoading = false
    }
    
    static func reduce(state: inout State, event: Event) {
        switch event {
            
        case .didStartNextLoading:
            state.isNextLoading = true
            
        case .didEndNextLoading:
            state.isNextLoading = false
            
        case let .didLoadNextBatch(cards):
            state.cards.append(contentsOf: cards.results)
            state.nextBatch = cards.next
        }
    }
    
    enum Event {
        case didStartNextLoading
        case didEndNextLoading
        case didLoadNextBatch(GwentAPI.Response.Cards)
    }
}

extension CardList.Event: Equatable {
    static func ==(lhs: CardList.Event, rhs: CardList.Event) -> Bool {
        switch (lhs, rhs) {
        case (.didStartNextLoading, .didStartNextLoading): return true
        case (.didEndNextLoading, .didEndNextLoading): return true
        case (.didLoadNextBatch(let lhs), .didLoadNextBatch(let rhs)) where lhs == rhs: return true
        default: return false }
    }
}
