//
//  FavouritesViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/6/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var favouritesTable: UITableView!
    let noFavLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.favouritesTable.delegate = self
        self.favouritesTable.dataSource = self
        self.favouritesTable.rowHeight = 70
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FavouriteBuses.instance.favourites.isEmpty{
            if self.noFavLabel.isHidden{
                self.noFavLabel.isHidden = false
            }
            noFavLabel.text = "❌ I see no favourites 🧐🧐🧐"
            noFavLabel.adjustsFontSizeToFitWidth = true
            noFavLabel.textAlignment = .center
            noFavLabel.center.x = self.view.center.x
            noFavLabel.center.y = self.view.center.y-30
            self.view.addSubview(noFavLabel)
        } else {
            self.noFavLabel.isHidden = true
            self.favouritesTable.reloadData()
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavouriteBuses.instance.favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("busInfoCell", owner: self, options: nil)?.first as? busInfoCell else {return UITableViewCell()}
        let favBus = FavouriteBuses.instance.favourites[indexPath.row]
        let bus = favBus.getBusStruct()
        cell.initRow(busInfo: bus)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { action, view, completed in
            
            let favBus = FavouriteBuses.instance.favourites[indexPath.row] 

            if FavouriteBuses.instance.removeFromFavourites(favBus: favBus){
                tableView.deleteRows(at: [indexPath], with: .automatic)
                let successAlert = UIAlertController(title: "Removed frm favourites", message: "✅ SUCCESS!", preferredStyle: .alert)
                self.present(successAlert, animated: true, completion: {
                    successAlert.dismiss(animated: true, completion: nil)
                })
                completed(true)
            }
        })
        return UISwipeActionsConfiguration(actions: [delete])
    }

}
