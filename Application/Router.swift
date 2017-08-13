import UIKit

struct Route {
    let canHandle: (UIStoryboardSegue, Any?) -> Bool
    let handle: (UIStoryboardSegue, Any?) -> ()
}

extension Route {
    init<T: UIViewController>(from viewController: UIViewController,
            to type: T.Type,
            do block: @escaping (T) -> ()) {
        canHandle = { segue, _ in
            guard viewController === segue.source else { return false }
            guard segue.destination is T else { return false }
            return true
        }
        
        handle = { segue, _ in block(segue.destination as! T) }
    }
}

class Router {
    let routes: [Route]
    init(routes: [Route]) { self.routes = routes }
    
    func handle(segue: UIStoryboardSegue, sender: Any?) {
        let route = routes.first {$0.canHandle(segue, sender) }
        route?.handle(segue, sender)
    }
}

