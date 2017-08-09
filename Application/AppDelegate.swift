import UIKit
import API

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var store = Store()
    var gwentAPI = GwentAPI()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window?.rootViewController = storyboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        guard let navigation = window?.rootViewController as? UINavigationController
            else { fatalError("root is not navigation") }
        
        guard let allCards = navigation.topViewController as? CardListViewController
            else { fatalError("first controller is not card list") }
        
        loadCards()
        
        _ = store.subscribe(action: ActionWith<State> { state in
            allCards.props = CardListViewController.Props.init(
                items: state.cards.map { $0.name },
                onItemsEnd: Action(perform: self.loadCards)
            )
        })
        
        return true
    }
    
    func loadCards() {
        guard store.state.isNextLoading == false else { return }
        guard store.state.nextBatch != nil || store.state.cards.isEmpty else { return }
        
        store.dispatch(event: .startNextLoading)
        gwentAPI.getCards(url: store.state.nextBatch).dispatch(on: .main)
            .onSuccess { self.store.dispatch(event: .didLoadNextBatch($0)) }
            .onComplete { _ in self.store.dispatch(event: .didEndNextLoading) }
    }
}
