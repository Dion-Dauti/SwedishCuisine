//
//  MenuViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-28.
//
import UIKit
class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!

    private let dbHelper = DatabaseHelper()
    private var menuItems: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadMenuItemsFromDatabase()
    }

    func loadMenuItemsFromDatabase() {
        menuItems = dbHelper.fetchMenuItems()
        tableView.reloadData()
    }

   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuItemViewCell

        let menuItem = menuItems[indexPath.row]
        cell.dishName.text = menuItem.name
        cell.dishPrice.text = "\(menuItem.price) kr"

      
        if let image = UIImage(contentsOfFile: menuItem.image) {
            cell.dishImage.image = image
        } else {
            cell.dishImage.image = UIImage(named: "caryfishdish")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

