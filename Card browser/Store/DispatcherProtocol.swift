/// This protocol is the basic component of interactive action creators
protocol Dispatcher {
    func dispatch(action: Action)
}

/// Is is possible to add some extensions which will implement
/// compatibility with differnt parts of the system
extension Dispatcher {
    func dispatch(future: Future<Action>) {
        future.onComplete(perform: dispatch)
    }
    
    func dispatch(command: CommandWith<Dispatcher>) {
        command.perform(with: self)
    }
}
