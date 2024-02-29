//
//  MenuViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-28.
//
import UIKit
class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!

    private let dbHelper = DatabaseHelper() // Create a DatabaseHelper instance
    private var menuItems: [MenuItem] = []  // Array to hold fetched data

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadMenuItemsFromDatabase() // Load data on view load
    }

    func loadMenuItemsFromDatabase() {
        menuItems = dbHelper.fetchMenuItems()
        tableView.reloadData() // Update the table view after fetching data
    }

    // ... other existing UITableViewDataSource and Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuItemViewCell // Cast to your custom cell

        let menuItem = menuItems[indexPath.row]
        cell.dishName.text = menuItem.name
        cell.dishPrice.text = "\(menuItem.price) kr"

        // Image loading (Assuming you have images stored locally):
        if let image = UIImage(contentsOfFile: menuItem.image) {
            cell.dishImage.image = image
        } else {
            // Set a placeholder image
            cell.dishImage.image = UIImage(named: "placeholderImage")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Replace with your desired height
    }
}

