//
//  HelpViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 6/13/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import MessageUI

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
        
        //assigning delegate to mailVC
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            case 0:
                UIApplication.shared.open(URL(string: "http://khadim054.com/how-to-use-catchBus.html")!, options: [:], completionHandler: nil)
            case 1:
                self.sendMail()
            case 2:
                UIApplication.shared.open(URL(string: "http://khadim054.com/how-to-use-catchBus.html")!, options: [:], completionHandler: nil)
            case 3:
                UIApplication.shared.open(URL(string: "http://khadim054.com/how-to-use-catchBus.html")!, options: [:], completionHandler: nil)
            
            default: break
            
        }
        
    }

}


//-------mail extenstion------
extension HelpViewController: MFMailComposeViewControllerDelegate{
    
    func sendMail(){
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        if MFMailComposeViewController.canSendMail(){
            mailVC.setToRecipients(["khadim1996@icloud.com"])
            mailVC.setSubject("contact us -")
            present(mailVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//-------end mail extenstion------
