//
//  StopDetailsViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/26/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class StopDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

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
        
        //register cell
        self.stopDetailTable.register(UINib(nibName: "busInfoCell", bundle: nil), forCellReuseIdentifier: "busInfoCellIdentifier")
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadStopDetailTable(handler: { completed in
            if completed{
                DispatchQueue.main.async {
                    self.stopDetailTable.reloadData()
                }
            } else {
                DispatchQueue.main.async {
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
    
    func loadStopDetailTable(handler: @escaping (_ completed: Bool)->()){
        
        DataService.instance.getBusInfoAtStop(withStopCode: currentStop.stopNo, handler: { data in
            if !data.isEmpty{
                self.busesAtThisStop = data
                handler(true)
            } else {
                handler(false)
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busesAtThisStop.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.stopDetailTable.dequeueReusableCell(withIdentifier: "busInfoCellIdentifier") as? busInfoCell else {return UITableViewCell()}
        cell.initRow(busInfo: self.busesAtThisStop[indexPath.row])
        return cell
    }
    

}
