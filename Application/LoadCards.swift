import Foundation
import API

enum Effect {
    case none
    case batch([Effect])
    case dispatch(Event)
    case loadCards(URL?, (Result<GwentAPI.Response.Cards>) -> Effect)
}

func loadCards(state: State) -> Effect {
    guard state.isNextLoading == false else { return .none }
    guard state.nextBatch != nil || state.cards.isEmpty else { return .none }
    
    return .batch(
        [ .dispatch(.didStartNextLoading),
          .loadCards(state.nextBatch) { result in
            .batch(
                [ result.value.map(Event.didLoadNextBatch).map(Effect.dispatch) ?? .none,
                  .dispatch(.didEndNextLoading)
                ])
            }
        ])
}

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
