//
//  TableViewController.swift
//  ContactsApp
//
//  Created by Vsevolod Lashin on 18.05.2023.
//

import UIKit
import AlamofireImage

final class ContactsTableViewController: UITableViewController {
        
    private var contacts: [User] = []
    private let networkManager = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
        downloadData()
        setupRefreshControl()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as? DetailContactViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let user = contacts[indexPath.row]
        detailVC?.user = user
    }
}

// MARK: - UITAbleViewDataSource
extension ContactListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.imageProperties.maximumSize = CGSize(width: 100, height: 100)
        content.imageProperties.cornerRadius = 50
        
        let contact = contacts[indexPath.row]
        content.text = contact.name.first
        content.secondaryText = contact.name.last
        
        networkManager.fetchData(from: contact.picture.thumbnail) { result in
            switch result {
            case .success(let imageData):
                content.image = UIImage(data: imageData)
                cell.contentConfiguration = content
            case .failure(let error):
                print(error)
            }
        }
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ContactListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            contacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Private Methods
extension ContactListViewController {
    private func downloadData() {
        networkManager.fetchUsers { [weak self] result in
            switch result {
            case .success(let contacts):
                self?.contacts = contacts
                self?.tableView.reloadData()
                if self?.refreshControl != nil {
                    self?.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl?.addTarget(self, action: #selector(downloadData), for: .valueChanged)
        let refreshAction = UIAction { [unowned self] _ in
            downloadData()
        }
        refreshControl?.addAction(refreshAction, for: .valueChanged)
    }
}
