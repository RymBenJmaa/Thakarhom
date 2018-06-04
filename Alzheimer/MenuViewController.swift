//
//  MenuViewController.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/15/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}



class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    /**
     *  Array to display menu options
     */
    
    @IBOutlet weak var tblMenuOptions: UITableView!
    
   
    /**
     *  Transparent button to hide menu
     */
    
    
    @IBOutlet weak var btnCloseMenuOverlay: UIButton!
    
    /**
     *  Array containing menu options
     */
    var arrayMenuOptions = [Dictionary<String,String>]()
    var arrayMenuOptions2 = [Dictionary<String,String>]()
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        //arrayMenuOptions.append(["title":"Sign up", "icon": "prof"])
        arrayMenuOptions.append(["title":"Description", "icon": "liste"  ])
        arrayMenuOptions.append(["title":"Symptomes", "icon":"symp"])
        arrayMenuOptions.append(["title":"Best practices", "icon": "check"])
        
        arrayMenuOptions.append(["title":"His/Her position", "icon":"m"])
        arrayMenuOptions.append(["title":"Advise of the day", "icon": "idea"])
        arrayMenuOptions.append(["title":"Contact a doctor", "icon": "contactt"])
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button: UIButton) {
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        switch (indexPath.section) {
        case 0:
            imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
            lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        /*case 1:
            imgIcon.image = UIImage(named: arrayMenuOptions2[indexPath.row]["icon"]!)
            lblTitle.text = arrayMenuOptions2[indexPath.row]["title"]!*/
        default:
            imgIcon.image = #imageLiteral(resourceName: "default")
            lblTitle.text = "default"
        }

        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       /* switch (section) {
        case 0:
            return arrayMenuOptions.count
        case 1:
            return arrayMenuOptions2.count
        default:
            return 3
        }*/
        return arrayMenuOptions.count + arrayMenuOptions2.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
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

