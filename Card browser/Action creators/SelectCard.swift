import Foundation

/// Action creator is a function which will return something, that you can dispatch:
/// - action
/// - CommandWith<Action>
/// - Future<Action>
/// - etc.
///
/// Any technic for passing dependency can work.
/// Here we use `parameter passing dependency`
/// Having explicit dependencies allows us to test it without any system mocking
func selectCard(link: CardLink, getURL: @escaping (URL) -> Future<Card> = getURL) -> CommandWith<Dispatcher> {
    return CommandWith { dispatcher in
        dispatcher.dispatch(action: DidSelectCard(link: link))
        dispatcher.dispatch(future:
            getURL(link.href).map(transform: DidLoadCard.init))
    }
}
