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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stopDetailTable.dataSource = self
        self.stopDetailTable.delegate = self
        self.stopDetailTable.rowHeight = 70
        
        // Do any additional setup after loading the view.
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.title = self.currentStop.stopName
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadStopDetailTable(handler: { completed, data in
            if completed{
                DispatchQueue.main.async {
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    self.stopDetailTableActivityIndicator.startAnimating()
                    
                    self.busesAtThisStop = data
                    self.stopDetailTable.reloadData()
                    
                    self.stopDetailTableActivityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            } else {
                DispatchQueue.main.async {
                    self.stopDetailTableActivityIndicator.removeFromSuperview()
                    
                    let noBusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
                    noBusLabel.text = "❌ No bus Available at this stop right now❗️"
                    noBusLabel.adjustsFontSizeToFitWidth = true
                    noBusLabel.textAlignment = .center
                    noBusLabel.center.x = self.stopDetailTable.center.x
                    noBusLabel.center.y = self.stopDetailTable.center.y-30
                    self.view.addSubview(noBusLabel)
                }
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadStopDetailTable(handler: @escaping (_ completed: Bool, _ data: [BusInfo] )->()){
        DataService.instance.getBusInfoAtStop(withStopCode: self.currentStop.stopNo, handler: { data in
            if !data.isEmpty{
                handler(true, data)
            } else {
                handler(false,[BusInfo]())
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
