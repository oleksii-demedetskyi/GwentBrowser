import API

enum Event {
    case didStartNextLoading
    case didEndNextLoading
    case didLoadNextBatch(GwentAPI.Response.Cards)
}

extension Event: Equatable {
    static func ==(lhs: Event, rhs: Event) -> Bool {
        switch (lhs, rhs) {
        case (.didStartNextLoading, .didStartNextLoading): return true
        case (.didEndNextLoading, .didEndNextLoading): return true
        case (.didLoadNextBatch(let lhs), .didLoadNextBatch(let rhs)) where lhs == rhs: return true
        default: return false }
    }
}
