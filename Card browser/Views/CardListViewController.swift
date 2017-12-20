import UIKit

class CardListViewController: UITableViewController {
    
    /// Each controller has props which are describing it state
    struct Props {
        let cards: [Card] // list of cards to display in a table view.
        let onLastCellDisplayed: Command? // command for triggering next page load
        
        /// Props should be self-contained, and has no link to the rest of the system
        struct Card {
            let name: String
            
            /// This is command for connecting next view controller
            /// Having context specific actions allows you to get rid of ids
            let select: CommandWith<UIViewController>
        }
        
        /// Default version of props.
        /// This is more preferrable than having `Props?` declarartion
        static let initial = Props(cards: [], onLastCellDisplayed: nil)
    }
    
    /// Storage of current props. Allows vc to implement deferred rendering
    /// Mutation of this property is expected to be in main thread.
    var props: Props = .initial {
        didSet { tableView.reloadData() }
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return props.cards.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// It is nice sanity check to catch some issues early.
        guard props.cards.indices.contains(indexPath.row) else {
            fatalError("Index: \(indexPath) is out of bounds")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "card") else {
            fatalError("Cannot get cell for single card")
        }
        
        cell.textLabel?.text = props.cards[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        if props.cards.indices.last == indexPath.row {
            props.onLastCellDisplayed?.perform()
        }
    }
    
    /// Calling back to the system when segue is about to be performed.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else {
            fatalError("Cannot start transition from sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            fatalError("Cannot get index path from cell: \(cell)")
        }
        
        guard props.cards.indices.contains(indexPath.row) else {
            fatalError("Index path \(indexPath) is out of bounds")
        }
        
        props.cards[indexPath.row].select.perform(with: segue.destination)
    }
}
