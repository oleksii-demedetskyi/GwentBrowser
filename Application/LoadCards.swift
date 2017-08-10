import Foundation
import API

func loadCards(api: GwentAPI) -> (State, ActionWith<Event>) -> () {
    return { state, dispatch in
        guard state.isNextLoading == false else { return }
        guard state.nextBatch != nil || state.cards.isEmpty else { return }
        
        dispatch.perform(.startNextLoading)
        api.getCards(url: state.nextBatch).dispatch(on: .main)
            .onSuccess { dispatch.perform(.didLoadNextBatch($0)) }
            .onComplete { _ in dispatch.perform(.didEndNextLoading) }
    }
}
