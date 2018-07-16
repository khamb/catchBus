//
//  FavouritesViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 6/6/18.
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
        
        //setting up no label view
        self.initNoFavLabel()
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

            self.favouritesTable.reloadData()

    }
    
    private func initNoFavLabel(){
        self.noFavLabel.text = "❌ I see no favourites 🧐🧐🧐"
        self.noFavLabel.adjustsFontSizeToFitWidth = true
        self.noFavLabel.textAlignment = .center
        self.noFavLabel.center.x = self.view.center.x
        self.noFavLabel.center.y = self.view.center.y-30
        self.favouritesTable.backgroundView = self.noFavLabel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FavouriteBuses.instance.favourites.isEmpty{
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        
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
                let successAlert = UIAlertController(title: "✅", message: "SUCCESS!", preferredStyle: .alert)
                self.present(successAlert, animated: true, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
                        successAlert.dismiss(animated: true, completion: nil)
                    })
                })
                completed(true)
            }
        })
        delete.image = UIImage(named: "delete")
        return UISwipeActionsConfiguration(actions: [delete])
    }

}
