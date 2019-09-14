import UIKit
import RealmSwift

class IphoneListTableViewController: UITableViewController {
    private var notificationToken: NotificationToken!
    
    private lazy var realm = try! Realm()
    
    private weak var okAction: UIAlertAction?
    
    private var phones: Results<Phones>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phones = realm.objects(Phones.self)
        
        notificationToken = phones.observe { [weak self] change in
            guard let self = self else { return }
            
            switch change {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .fade)
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .fade)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .fade)
                self.tableView.endUpdates()
            case .error(let error):
                print(error)
            }
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    deinit {
        notificationToken.invalidate()
    }
    
    @objc func refreshAction() {
        phones = phones!.sorted(byKeyPath: "price", ascending: true)
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }

    @IBAction func addAction(_ sender: Any) {
        let alert = UIAlertController(title: "Add iPhone", message: "Enter model and price of iPhone", preferredStyle: .alert)
        
        alert.addTextField { (model) in
            model.text = ""
            model.placeholder = "some iPhone"
        }
        alert.addTextField { (price) in
            price.text = ""
            price.placeholder = "some price in USD"
        }
        
        let okAction = UIAlertAction(title: "Add", style: .default, handler: { action in
            let modelTextField = alert.textFields![0]
            let priceTextField = alert.textFields![1]
            
            guard let model = modelTextField.text, !model.isEmpty else { return }
            guard let price = priceTextField.text, !price.isEmpty else { return }
            
            let newPhone = Phones()
            newPhone.model = model
            newPhone.price = price
            try! self.realm.write {
                self.realm.add(newPhone)
            }
        })
        
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phones.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let phone = phones[indexPath.row]
        cell.textLabel?.text = "iPhone " + phone.model!
        cell.detailTextLabel?.text = "$ " + phone.price!
        
        print(phone)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let phone = phones[indexPath.row]
            try! realm.write {
                realm.delete(phone)
            }
            //            tableView.beginUpdates()
            //            tableView.deleteRows(at: [indexPath], with: .left)
            //            tableView.endUpdates()
        }
    }
    
}
