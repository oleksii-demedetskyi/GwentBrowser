extension Future {
    func map<U>(transform: @escaping (T) -> U) -> Future<U> {
        return Future<U> { complete in
            self.onComplete { t in complete(transform(t)) }
        }
    }
}
