import UIKit

class CardDetailsViewController: UIViewController {
    struct Props {
        let name: String
    }
    
    var props: Props = Props(name: "Default name") {
        didSet {
            title = props.name
        }
    }
}
