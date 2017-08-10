import UIKit

typealias Action = ActionWith<Void>

struct ActionWith<T> {
    let perform: (T) -> Void
}

class CardListViewController: UITableViewController {
    struct Props {
        let items: [String]
        let onItemsEnd: Action?
        
        static let empty = Props(items: [], onItemsEnd: nil)
    }
    
    var props: Props = .empty { didSet { tableView.reloadData() } }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(props.items.indices.contains(indexPath.row),
                     "Cannot display row: \(indexPath.row) in props: \(props)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "list.card") else {
            fatalError("Cannot get cell with list.card identifier")
        }
        
        if (props.items.indices.last == indexPath.row) {
            props.onItemsEnd?.perform()
        }
        
        cell.textLabel?.text = props.items[indexPath.row]
        
        return cell
    }
}
