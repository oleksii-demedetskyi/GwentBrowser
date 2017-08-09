import Foundation

final public class Future<Value> {
    public typealias Promise = (Value) -> ()
    
    public init(value: Value) {
        self.complete(with: value)
    }
    
    public init(work: (@escaping Promise) -> Void) {
        work(self.complete(with:))
    }
    
    private var value: Value?
    
    private func complete(with value: Value) {
        guard self.value == nil else { return }
        
        self.value = value
        
        for callback in self.callbacks {
            callback(value)
        }
        
        self.callbacks = []
    }
    
    private var callbacks: [Promise] = []
    
    @discardableResult public func onComplete(callback: @escaping Promise) -> Future {
        if let value = self.value {
            callback(value)
        } else {
            self.callbacks.append(callback)
        }
        
        return self
    }
}

extension Future {
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Future<NewValue> {
        return Future<NewValue> { promise in
            self.onComplete { value in
                promise(transform(value))
            }
        }
    }
}

extension Future {
    public func then<NewValue>(_ perform: @escaping (Value) -> Future<NewValue>) -> Future<NewValue> {
        return Future<NewValue> { complete in
            self.onComplete { value in
                perform(value).onComplete(callback: complete)
            }
        }
    }
}

extension Future {
    public func and<AnotherValue>(_ future: Future<AnotherValue>) -> Future<(Value, AnotherValue)> {
        return Future<(Value, AnotherValue)> { complete in
            self.onComplete { (value: Value) in
                future.onComplete { (anotherValue: AnotherValue) in
                    complete((value, anotherValue))
                }
            }
        }
    }
}

extension Future {
    public func dispatch(on queue: DispatchQueue) -> Future {
        return Future { complete in
            self.onComplete { value in
                queue.async {
                    complete(value)
                }
            }
        }
    }
}

extension Future {
    static var empty: Future<Void> { return Future<Void>(value: ()) }
}

extension Future {
    public func map(_ patch: @escaping (inout Value) -> Void) -> Future {
        return self.map { (value:Value) in
            var value = value
            patch(&value)
            return value
        }
    }
}

extension URLSession {
    func dataFuture(with request: URLRequest) -> Future<(Data?, URLResponse?, Error?)> {
        return Future { self.dataTask(with: request, completionHandler: $0).resume() }
    }
    
    func dataFuture(with url: URL) -> Future<(Data?, URLResponse?, Error?)> {
        return Future { self.dataTask(with: url, completionHandler: $0).resume() }
    }
}

