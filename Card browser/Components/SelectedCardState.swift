import Foundation

/// Component state can be modelled as enum as well as struct
enum SelectedCardState {
    case none
    case loading(CardLink)
    case loaded(Card)
    
    static let initial = SelectedCardState.none
}

func reduce(_ state: SelectedCardState, with action: Action) -> SelectedCardState {
    switch action {
    case let action as DidSelectCard: return .loading(action.link)
    case let action as DidLoadCard: return .loaded(action.card)
    default: return state }
}
