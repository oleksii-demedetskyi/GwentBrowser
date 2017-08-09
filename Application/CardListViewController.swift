import UIKit

// HERE:
typealias Action = ActionWith<Void>

struct ActionWith<T> {
    let perform: (T) -> Void
}

class CardListViewController: UITableViewController {
    // HERE:
    struct Props {
        let items: [String]
        let onItemsEnd: Action?
        
        static let empty = Props(items: [], onItemsEnd: nil)
    }
    
    // HERE:
    var props: Props = .empty { didSet { tableView.reloadData() } }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // HERE:
        return props.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(props.items.indices.contains(indexPath.row),
                     "Cannot display row: \(indexPath.row) in props: \(props)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "list.card") else {
            fatalError("Cannot get cell with list.card identifier")
        }
        
        if indexPath.row + 1 == props.items.count { props.onItemsEnd?.perform() }
        
        // HERE:
        cell.textLabel?.text = props.items[indexPath.row]
        
        return cell
    }
}
