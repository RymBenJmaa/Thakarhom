//
//  BestPractices.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/16/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit

class BestPractices: UIViewController , CPSliderDelegate {
    let _AUTO_SCROLL_ENABLED : Bool = true
    
    @IBOutlet weak var circularSwitch: UISwitch!
    
    @IBOutlet weak var autoSwitch: UISwitch!
    func sliderImageTapped(slider: CPImageSlider, index: Int) {
        print("ok")
    }
    

   
    @IBOutlet weak var slider: CPImageSlider!
    
    
    var imagesArray = [String]()
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesArray = ["1.png","3.png","8.png","6.png","7.png","2.png","4.jpg","5.png","9.png","10.png","11.png","12.png"]
        slider.images = imagesArray
        slider.delegate = self
        let zoom : CGFloat = 0.8
        autoSwitch.transform = CGAffineTransform(scaleX: zoom, y: zoom)
       // arrowSwitch.transform = CGAffineTransform(scaleX: zoom, y: zoom)
       // indicatorSwitch.transform = CGAffineTransform(scaleX: zoom, y: zoom)
        //sliderSwitch.transform = CGAffineTransform(scaleX: zoom, y: zoom)
        circularSwitch.transform = CGAffineTransform(scaleX: zoom, y: zoom)
        
        autoSwitch.isOn = slider.autoSrcollEnabled
        slider.enableArrowIndicator = true
        slider.enablePageIndicator = true
        slider.enableSwipe = true
        circularSwitch.isOn = slider.allowCircular
     
    }
    
    @IBAction func circular(_ sender: Any) {
        slider.allowCircular = circularSwitch.isOn
    }
    
    @IBAction func auto(_ sender: Any) {
  slider.autoSrcollEnabled = autoSwitch.isOn
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

