import Foundation

/// Top level state is usually a composition of different domain states.
struct State {
    let cardList: CardListState
    let selectedCard: SelectedCardState
    
    static let initial = State(
        cardList: CardListState.initial,
        selectedCard: SelectedCardState.initial)
}

/// Reduce for composit states is trivial
func reduce(_ state: State, with action: Action) -> State {
    return State(
        cardList: reduce(state.cardList, with: action),
        selectedCard: reduce(state.selectedCard, with: action))
}
