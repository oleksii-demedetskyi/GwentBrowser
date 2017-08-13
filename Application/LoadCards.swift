import Foundation
import API

func loadCards(api: @escaping (URL?) -> Future<Result<GwentAPI.Response.Cards>>)
    -> (Application.State, ActionWith<Application.Event>) -> () {
    return { state, dispatch in
        guard state.cardList.isNextLoading == false else { return }
        guard state.cardList.nextBatch != nil || state.cardList.cards.isEmpty else { return }
        
        dispatch.perform(.cardList(.didStartNextLoading))
        api(state.cardList.nextBatch)
            .onSuccess { dispatch.perform(.cardList(.didLoadNextBatch($0))) }
            .onComplete { _ in dispatch.perform(.cardList(.didEndNextLoading)) }
    }
}
