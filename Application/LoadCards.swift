import Foundation
import API

func loadCards(api: @escaping (URL?) -> Future<Result<GwentAPI.Response.Cards>>) -> (State, ActionWith<Event>) -> () {
    return { state, dispatch in
        guard state.isNextLoading == false else { return }
        guard state.nextBatch != nil || state.cards.isEmpty else { return }
        
        dispatch.perform(.didStartNextLoading)
        api(state.nextBatch)
            .onSuccess { dispatch.perform(.didLoadNextBatch($0)) }
            .onComplete { _ in dispatch.perform(.didEndNextLoading) }
    }
}
