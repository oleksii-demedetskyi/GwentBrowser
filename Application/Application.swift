enum Application {
    struct State {
        var cardList = CardList.State()
    }
    
    static func reduce(state: inout State, event: Event) {
        switch event {
        case let .cardList(event):
            CardList.reduce(state: &state.cardList, event: event)
        }
    }
    
    enum Event {
        case cardList(CardList.Event)
    }
}

extension Application.Event: Equatable {
    static func ==(lhs: Application.Event, rhs: Application.Event) -> Bool {
        switch (lhs, rhs) {
        case let (.cardList(lhs), .cardList(rhs)) where lhs == rhs: return true
        default: return false }
    }
}
