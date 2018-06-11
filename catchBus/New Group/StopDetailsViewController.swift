//
//  StopDetailsViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/26/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class StopDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var stopDetailTableActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stopDetailTable: UITableView!
    var currentStop = Stop(stopNo: "", stopName: "")
    var busesAtThisStop = [BusInfo]()
    
    let noBusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stopDetailTable.dataSource = self
        self.stopDetailTable.delegate = self

        // Do any additional setup after loading the view.
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = self.currentStop.stopName
        
        self.setupTableRefresher()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadStopDetailTable()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configNoBusLabel(){
        self.noBusLabel.text = "❌ No bus Available at this stop right now❗️"
        self.noBusLabel.adjustsFontSizeToFitWidth = true
        self.noBusLabel.textAlignment = .center
        self.noBusLabel.center.x = self.stopDetailTable.center.x
        self.noBusLabel.center.y = self.stopDetailTable.center.y-30
        self.view.addSubview(self.noBusLabel)
    }
    
    
    func loadStopDetailTable(){//make api request and populate the table datasource

        DataService.instance.getBusInfoAtStop(withStopCode: self.currentStop.stopNo, handler: { data in
            if !data.isEmpty{
                self.busesAtThisStop = data
                
                DispatchQueue.main.async {
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    self.stopDetailTableActivityIndicator.startAnimating()

                    self.stopDetailTable.reloadData() //try to reload visible rows

                    self.stopDetailTableActivityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }

            } else {
                DispatchQueue.main.async {
                    self.stopDetailTableActivityIndicator.isHidden = true
                    self.configNoBusLabel()
                }
            }
        })

        
    }
    
    
    @objc func refreshStopsTable(){
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.stopDetailTable.refreshControl?.beginRefreshing()
        self.loadStopDetailTable()
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.stopDetailTable.refreshControl?.endRefreshing()
            UIApplication.shared.endIgnoringInteractionEvents()
        })

    }
    
    func setupTableRefresher(){
        self.stopDetailTable.refreshControl = UIRefreshControl()
        self.stopDetailTable.refreshControl?.addTarget(self, action: #selector(StopDetailsViewController.self.refreshStopsTable), for: .valueChanged)
        self.stopDetailTable.refreshControl?.attributedTitle = NSAttributedString(string: "reloading ...")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busesAtThisStop.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("busInfoCell", owner: self, options: nil)?.first as? busInfoCell else {return UITableViewCell()}

        cell.initRow(busInfo: self.busesAtThisStop[indexPath.row])
        return cell
    }
    

}
