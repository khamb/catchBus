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
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar = UISearchBar()
    var filteredStops = [Stop]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.stopsTable.dataSource = self
        self.stopsTable.delegate = self
        
        //init rowHeight
        self.stopsTable.rowHeight = 50
        
        //embedding search bar in navigation bar and initialize it
        self.initSearchBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.stopsTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSearchBar(){
        self.searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.navigationItem.searchController = self.searchController
        self.searchBar = (self.navigationItem.searchController?.searchBar)!
        //self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchBar.delegate = self
        self.searchBar.placeholder = "search by stop name..."
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !(self.searchController.searchBar.text?.isEmpty)!{
            self.filteredStops = ViewController.allStops.filter({ stop in
                return stop.stopName.contains(searchText.uppercased())
            })
            self.stopsTable.reloadData()
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let stopDetailVC = segue.destination as? StopDetailsViewController else {return}
        guard let cellSender = sender as? StopCell else {return}
        
        if let index = self.stopsTable.indexPath(for: cellSender){
            stopDetailVC.currentStop = ViewController.allStops[index.row]
        }
        
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchBar.text?.isEmpty)!{
            return ViewController.allStops.count
        }
        return self.filteredStops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopCell = tableView.dequeueReusableCell(withIdentifier: "StopCell") as? StopCell else {return UITableViewCell()}
        
        if (self.searchController.searchBar.text?.isEmpty)!{
            stopCell.initCell(stop: ViewController.allStops[indexPath.row])
        } else {
            stopCell.initCell(stop: self.filteredStops[indexPath.row])
        }

        return stopCell
    }
    
}


