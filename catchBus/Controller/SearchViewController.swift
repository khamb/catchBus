//
//  SearchViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/23/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var stopsTable: UITableView!
    
    let searController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.stopsTable.dataSource = self
        self.stopsTable.delegate = self
        
        //init rowHeight
        self.stopsTable.rowHeight = 50
        
        //embedding search bar in navigation bar
        self.navigationItem.searchController = self.searController
        let searchBar = self.navigationItem.searchController?.searchBar
        searchBar?.delegate = self
        searchBar?.placeholder = "search by stop name..."
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.stopsTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ViewController.allStops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopCell = tableView.dequeueReusableCell(withIdentifier: "StopCell") as? StopCell else {return UITableViewCell()}
        stopCell.initCell(stop: ViewController.allStops[indexPath.row])
        return stopCell
    }
    
    
}


