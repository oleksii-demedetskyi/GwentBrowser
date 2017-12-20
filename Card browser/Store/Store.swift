import Foundation

/// Reducer is a rule to proceed from current state to a new one
typealias Reducer<State> = (State, Action) -> State

/// Store is a single mutation point of our app state.
/// Store is a natural dispathcer
final class Store<State>: Dispatcher {
    
    /// It have it is own queue, where all access and mutation is performed
    private let queue = DispatchQueue(label: "store private queue")
    
    /// Current app state is stored here
    private var state: State
    
    private var reducer: Reducer<State>
 
    /// Also, store need to notify everyone about state changes
    private var subscribers: Set<CommandWith<State>> = []
    
    init(state: State, reducer: @escaping Reducer<State>) {
        self.state = state
        self.reducer = reducer
    }
    
    /// Dispatch is async by nature.
    func dispatch(action: Action) {
        queue.async {
            self.state = self.reducer(self.state, action)
            self.subscribers.forEach { $0.perform(with: self.state) }
        }
    }
    
    /// Observing a store will return a `Command` to stop observation
    @discardableResult
    func observe(with command: CommandWith<State>) -> Command {
        queue.async {
            self.subscribers.insert(command)
            command.perform(with: self.state)
        }
        
        /// Cancel observing should not keep link to command, so we need to use `weak` here
        let endObserving = Command(id: "Dispose observing for \(command)") { [weak command] in
            guard let command = command else { return }
            self.subscribers.remove(command)
            }.dispatched(on: queue) // Also mutation of `subscribers` need to be protected by queue
        
        /// `queue` is a serial queue,
        /// so add observing will always be performed before `endObserving` block
        
        return endObserving
    }
}
