import Foundation

/// Simplest dispatchable type is prefferred
/// It is usually easier to test
func loadCards(url: URL, getURL: @escaping (URL) -> Future<CardsResponse> = getURL) -> Future<Action> {
    return getURL(url).map(transform: DidLoadCardLinks.init)
}

