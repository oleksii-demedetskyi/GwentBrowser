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

class Store<State, Event> {
    private(set) var state: State
    private let reduce: (inout State, Event) -> ()
    
    init(state: State, reduce: @escaping (inout State, Event) -> ()) {
        self.state = state
        self.reduce = reduce
    }
    
    func dispatch(event: Event) {
        reduce(&state, event)
        subscribers.forEach { $0.value.perform(state) }
    }
    
    func dispatch(creator: (State, ActionWith<Event>) -> ()) {
        creator(state, ActionWith(perform: dispatch(event:)))
    }
    
    func bind(creator: @escaping (State, ActionWith<Event>) -> ()) -> Action {
        return Action { self.dispatch(creator: creator) }
    }
    
    private var subscribers = [:] as [UUID: ActionWith<State>]
    
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

