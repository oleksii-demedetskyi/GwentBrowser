import Foundation

/// This enum represents a result of some computation.
public enum Result<T> {
    case value(T)
    case error(Error)
}

extension Result {
    public func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case let .error(error): return .error(error)
        case let .value(value): return .value(transform(value))
        }
    }
    
    public func map(_ patch: (inout T) -> Void) -> Result {
        switch self {
        case var .value(value):
            patch(&value)
            return .value(value)
            
        default: return self
        }
    }
}

extension Result {
    public func mapError(_ transform: (Error) -> Error) -> Result<T> {
        switch self {
        case .error(let error): return .error(transform(error))
        case .value: return self
        }
    }
}


extension Result {
    public func flatMap<U>(_ transform: (T) -> Result<U>) -> Result<U> {
        switch self {
        case let .error(error): return .error(error)
        case let .value(value): return transform(value)
        }
    }
    
    public func flatMap<U>(_ transform: (T) throws -> U) -> Result<U> {
        switch self {
        case let .error(error): return .error(error)
        case let .value(value):
            do { return .value(try transform(value)) }
            catch let error { return .error(error) }
        }
    }
}

extension Result {
    public var value: T? {
        guard case let .value(value) = self else { return nil }
        return value
    }
    
    public var error: Error? {
        guard case let .error(error) = self else { return nil }
        return error
    }
}

extension Result {
    public func map<U>(value valueTransform: (T) -> U, error errorTransform: (Error) -> U) -> U {
        switch self {
        case let .error(error): return errorTransform(error)
        case let .value(value): return valueTransform(value)
        }
    }
}

extension Result {
    public func extract<U>(transforms: (value: (T) -> U, error: (Error) -> U)) -> U {
        switch self {
        case let .error(error): return transforms.error(error)
        case let .value(value): return transforms.value(value) }
    }
}

public protocol ResultType {
    associatedtype ValueType
    
    var asResult: Result<ValueType> { get }
}

extension  Result: ResultType {
    public typealias ValueType = T
    
    public var asResult: Result<ValueType> { return self }
}

extension Future where Value: ResultType {
    public typealias ResultValue = Value
    
    @discardableResult public func onSuccess(call callback: @escaping (ResultValue.ValueType) -> Void) -> Future {
        return self.onComplete { result in
            guard case let .value(value) = result.asResult else { return }
            callback(value)
        }
    }
    
    @discardableResult public func onError(call callback: @escaping (Error) -> Void) -> Future {
        return self.onComplete { result in
            guard case let .error(error) = result.asResult else { return }
            callback(error)
        }
    }
    
    public func map<NewType>(_ transform: @escaping (ResultValue.ValueType) -> NewType) -> Future<Result<NewType>> {
        return self.map { $0.asResult.map(transform) }
    }
    
    public func map(_ patch: @escaping (inout ResultValue.ValueType) -> Void) -> Future<Result<ResultValue.ValueType>> {
        return self.map { $0.asResult.map(patch) }
    }
    
    public func map<NewType>(_ transform: @escaping (ResultValue.ValueType) -> Result<NewType>) -> Future<Result<NewType>> {
        return self.map { $0.asResult.flatMap(transform) }
    }
    
    public func map<NewType>(_ transform: @escaping (ResultValue.ValueType) throws -> NewType) -> Future<Result<NewType>> {
        return self.map { $0.asResult.flatMap(transform) }
    }
    
    public func mapError(_ transform: @escaping (Error) -> Error) -> Future<Result<ResultValue.ValueType>> {
        return self.map { $0.asResult.mapError(transform) }
    }
    
    public func map<NewType>(_ transforms: (
        value: (ResultValue.ValueType) -> NewType,
        error: (Error) -> NewType)) -> Future<NewType> {
        return self.map { $0.asResult.extract(transforms: transforms) }
    }
    
    public func then<NewType>(_ perform: @escaping (ResultValue.ValueType) -> Future<NewType>) -> Future<Result<NewType>> {
        return self.then { (result: ResultValue) in
            switch result.asResult {
            case let .error(error): return Future<Result<NewType>>(value: .error(error))
            case let .value(value): return perform(value).map(Result<NewType>.value)
            }
        }
    }
    
    public func then<NewType>(_ perform: @escaping (ResultValue.ValueType) -> Future<Result<NewType>>) -> Future<Result<NewType>> {
        return self.then { (result: ResultValue) in
            switch result.asResult {
            case let .error(error): return Future<Result<NewType>>(value: .error(error))
            case let .value(value): return perform(value)
            }
        }
    }
}

extension Future {
    func map<NewType>(_ transform: @escaping (Value) throws -> NewType) -> Future<Result<NewType>> {
        return self.map { value in
            do { return try .value(transform(value)) }
            catch let error { return .error(error) }
        }
    }
}
