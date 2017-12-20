import Foundation

struct CardListState {
    let links: [CardLink]
    let nextPageURL: URL?
    
    static let initial = CardListState(links: [], nextPageURL: nil)
}

/// Rule of thumb for all reducer is to return state untouched if action is out of interest
func reduce(_ state: CardListState, with action: Action) -> CardListState {
    switch action {
    case let action as DidLoadCardLinks:
        return CardListState(links: state.links + action.response.results,
                             nextPageURL: action.response.next)
    default: return state }
}
