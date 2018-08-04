//
//  StopDetailsViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 6/3/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class StopDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var stopDetailTable: UITableView!
    var currentStop = Stop(stopNo: "", stopName: "")
    var busesAtThisStop = [BusInfo]()
    
    let noBusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    let loadingAlert = UIAlertController(title: "Loading", message: nil, preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stopDetailTable.dataSource = self
        self.stopDetailTable.delegate = self

        // Do any additional setup after loading the view.
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = self.currentStop.stopName
        
        self.setupTableRefresher()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.present(self.loadingAlert, animated: true, completion:{
            self.loadStopDetailTable()
            
        })
        DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
            self.loadingAlert.dismiss(animated: true, completion: nil)
        })
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
        self.stopDetailTable.backgroundView = self.noBusLabel
    }
    
    
    func loadStopDetailTable(){//make api request and populate the table datasource

        DataService.instance.getBusInfoAtStop(stops: [self.currentStop], handler: { data in
            DispatchQueue.main.async {
                if !data.isEmpty{
                    self.busesAtThisStop = data
                
                    self.stopDetailTable.reloadData() //try to reload visible rows
                    
                } else {
                    self.configNoBusLabel()
                }
            }
        })
        
    }
    
    
    @objc func refreshStopsTable(){
        self.stopDetailTable.refreshControl?.beginRefreshing()
        self.loadStopDetailTable()
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.stopDetailTable.refreshControl?.endRefreshing()
        })

    }
    
    func setupTableRefresher(){
        self.stopDetailTable.refreshControl = UIRefreshControl()
        self.stopDetailTable.refreshControl?.addTarget(self, action: #selector(StopDetailsViewController.self.refreshStopsTable), for: .valueChanged)
        self.stopDetailTable.refreshControl?.attributedTitle = NSAttributedString(string: "Reloading ...")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.busesAtThisStop.isEmpty{
            self.stopDetailTable.backgroundView?.isHidden = false
        }else{
           self.stopDetailTable.backgroundView?.isHidden = true
        }
        return self.busesAtThisStop.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("busInfoCell", owner: self, options: nil)?.first as? busInfoCell else {return UITableViewCell()}

        cell.initRow(busInfo: self.busesAtThisStop[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "") { (action, view, completed) in
            let favBus = FavBusInfo(busInfo: self.busesAtThisStop[indexPath.row], stop: self.currentStop)
            
            if FavouriteBuses.instance.addToFavourites(favBus: favBus){
                let alert = UIAlertController(title: "✅", message: "SUCCESS!", preferredStyle: .alert)
                self.present(alert, animated: true, completion:{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                completed(true)
            } else {
                let alert = UIAlertController(title: "❌", message: "ALREADY IN YOUR FAVOURITES!", preferredStyle: .alert)
                self.present(alert, animated: true, completion:{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                
                completed(true)
            }
        }
        favorite.image = UIImage(named: "fav")
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    

}
