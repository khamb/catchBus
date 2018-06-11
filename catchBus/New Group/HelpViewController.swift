//
//  HelpViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 6/9/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var usefulLinksTable: UITableView!
    let usefulLinks = ["How to use the app","Contact Us", "Terms and Privacy Policy", "Licences"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usefulLinksTable.dataSource = self
        self.usefulLinksTable.delegate = self
        // Do any additional setup after loading the view.
        self.usefulLinksTable.isScrollEnabled = false
        self.usefulLinksTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usefulLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = self.usefulLinks[indexPath.row]
        cell.accessoryType = .disclosureIndicator
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
