//
//  SearchViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/23/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //seting up search bar
        self.navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController?.searchBar.placeholder = "search by stop name..."

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
