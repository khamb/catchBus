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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favouritesTable.delegate = self
        self.favouritesTable.dataSource = self
        // Do any additional setup after loading the view.
        print(FavouriteBuses.instance.favourites.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavouriteBuses.instance.favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("busInfoCell", owner: self, options: nil)?.first as? busInfoCell else {return UITableViewCell()}
        cell.initRow(busInfo: FavouriteBuses.instance.favourites[indexPath.row])
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
