import UIKit

class CardDetailsViewController: UIViewController {
    
    /// Structure of props is similar for every component:
    /// - declarations
    /// - nested types
    /// - initial, init, other methods.
    struct Props {
        let name: String
        let onDestroy: Command?
        let state: State
        
        enum State {
            case loading
            case card(Card)
        }
        
        struct Card {
            let flavor: String
            let power: String
            let description: String
        }
        
        static let initial = Props(name: "", onDestroy: nil, state: .loading)
    }
    
    var props: Props = .initial {
        didSet {
            /// This allows us to defer rendering for view controller which are not visible yet.
            guard isViewLoaded else { return }
            
            /// This allows UIKit to keep 60 frames, and skip unneeded props rendering
            view.setNeedsLayout()
        }
    }
    
    /// All IBOutlets should be `private`
    
    @IBOutlet private var flavor: UILabel!
    @IBOutlet private var power: UILabel!
    @IBOutlet private var cardDescription: UILabel!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
    
    /// Usually in this func we perform rendering props to each UI element
    override func viewWillLayoutSubviews() {
        title = props.name
        
        /// This style is more robust in support.
        /// Having no dependency between each component,
        /// and the rest of the input options is the key.
        loadingIndicator.isHidden = result {
            guard case .card = props.state else { return false }
            return true
        }
        
        power.isHidden = !loadingIndicator.isHidden
        flavor.isHidden = !loadingIndicator.isHidden
        cardDescription.isHidden = !loadingIndicator.isHidden
        
        flavor.text = result {
            guard case .card(let card) = props.state else { return "" }
            return card.flavor
        }
        
        power.text =  result {
            guard case .card(let card) = props.state else { return "" }
            return "Power: \(card.power)"
        }
        
        cardDescription.text = result {
            guard case .card(let card) = props.state else { return "" }
            return card.description
        }
    }
    
    /// Sometimes system want to know when we are done. 
    deinit {
        props.onDestroy?.perform()
    }
}
