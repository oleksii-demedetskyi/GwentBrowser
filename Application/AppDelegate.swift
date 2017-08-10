import UIKit
import API

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var store = Store(state: State(), reduce: reduce)
    var gwentAPI = GwentAPI()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window?.rootViewController = storyboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        guard let navigation = window?.rootViewController as? UINavigationController
            else { fatalError("root is not navigation") }
        
        guard let allCards = navigation.topViewController as? CardListViewController
            else { fatalError("first controller is not card list") }
        
        let loadCards = store.bind(creator: Application.loadCards(api: gwentAPI.getCards(url:)))
        
        loadCards.perform()
        
        _ = store.subscribe(action: ActionWith<State> { state in
            allCards.props = CardListViewController.Props.init(
                items: state.cards.map { $0.name },
                onItemsEnd: loadCards
            )
        })
        
        return true
    }
}
