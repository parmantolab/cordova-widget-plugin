//
//  TodayViewController.swift
//  MedicalWidget
//
//  Created by Zhendong Wang on 7/12/17.
//  Copyright © 2017 Zhendong Wang. All rights reserved.
//

import UIKit
import NotificationCenter



class TextCellView: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var content: UILabel!
}

class ContactCellView: UITableViewCell {
    
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mobileTypeLabel: UILabel!
    
    @IBAction func makePhoneCall(_ sender: Any) {
        if let url = URL(string: "tel://" + phone) {
            self.extensionContext?.open(url, completionHandler: { (success) in
                NSLog("\(success)")
            })
        }

    }
    var phone:String = ""
    var extensionContext:NSExtensionContext?
}


class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var data:[[String:String]] = []
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let value = data[indexPath.row]
        
        if value["type"] == "contact" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contact", for: indexPath) as! ContactCellView
            cell.relationLabel.text = value["relationship"]
            cell.nameLabel.text = value["name"]
            cell.phoneLabel.text = value["phone"]
            cell.mobileTypeLabel.text = value["phone_type"]
            cell.phone = value["phone"] ?? ""
            cell.extensionContext = self.extensionContext
            return cell
            
            
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! TextCellView
            cell.label.text = value["name"]
            cell.content.text = value["value"]
            return cell
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let group = UserDefaults(suiteName: "group.tony.app-widget-e1") {
            group.synchronize()
            parseNormalValue(forkey: "Medical Condition", toArray: &data, group: group)
            parseNormalValue(forkey: "Medical Notes", toArray: &data, group: group)
            parseNormalValue(forkey: "Allergeies & Reactions", toArray: &data, group: group)
            parseNormalValue(forkey: "Medications", toArray: &data, group: group)
            parseContactValue(forkey: "Emergency Contact", toArray: &data, group: group)
            parseNormalValue(forkey: "Blood Type", toArray: &data, group: group)
            parseNormalValue(forkey: "Weight", toArray: &data, group: group)
            parseNormalValue(forkey: "Height", toArray: &data, group: group)
            initView()
            tableView.dataSource = self
            
        }
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
        
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: 0, height: 2000)
        } else {
            preferredContentSize = maxSize
        }
    }
    
    
    func initView(){
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()// Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func parseNormalValue(forkey:String, toArray:inout Array<Dictionary<String,String>>, group:UserDefaults){
        if let value = group.string(forKey: forkey) {
            toArray.append([
                "type":"normal",
                "name":forkey,
                "value":value
                ])
        }
        
    }
    
    func parseContactValue(forkey:String, toArray:inout Array<Dictionary<String,String>>, group:UserDefaults){
        if let contacts = group.object(forKey: forkey){
            let _contacts = contacts as! Array<Dictionary<String,String>>
            for contact in _contacts {
                let _contact:Dictionary<String,String> = [
                    "relationship":contact["relationship"]!,
                    "name":contact["name"]!,
                    "phone":contact["phone"]!,
                    "phone_type":contact["phone_type"]!,
                    "type":"contact"
                ]
                
                toArray.append(_contact)
            }
            
        }
        
    }
    
}
