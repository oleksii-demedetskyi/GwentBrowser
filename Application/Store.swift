import Foundation

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

