import UIKit

class CardListViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 /* Magic */
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "list.card") else {
            fatalError("Cannot get cell with list.card identifier")
        }
        
        cell.textLabel?.text = "Magic"
        
        return cell
    }
}
