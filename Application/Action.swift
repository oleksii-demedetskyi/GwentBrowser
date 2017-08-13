struct ActionWith<T> {
    let perform: (T) -> Void
}

typealias Action = ActionWith<Void>

extension ActionWith {
    func bind(with value: T) -> Action {
        return Action { self.perform(value) }
    }
}
