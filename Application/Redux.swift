import Foundation
import API

struct State {
    var cards = [] as [GwentAPI.Response.CardLink]
    var nextBatch = nil as URL?
    var isNextLoading = false
}

func reduce(state: inout State, event: Event) {
    switch event {
        
    case .startNextLoading:
        state.isNextLoading = true
        
    case .didEndNextLoading:
        state.isNextLoading = false
        
    case let .didLoadNextBatch(cards):
        state.cards.append(contentsOf: cards.results)
        state.nextBatch = cards.next
    }
}

enum Event {
    case startNextLoading
    case didEndNextLoading
    case didLoadNextBatch(GwentAPI.Response.Cards)
}

class Store {
    private(set) var state = State()
    private var subscribers = [:] as [UUID: ActionWith<State>]
    
    func dispatch(event: Event) {
        reduce(state: &state, event: event)
        subscribers.forEach { $0.value.perform(state) }
    }
    
    func subscribe(action: ActionWith<State>) -> UUID {
        let id = UUID()
        subscribers[id] = action
        action.perform(state)
        
        return id
    }
    
    func unsubscribe(id: UUID) {
        subscribers[id] = nil
    }
}
