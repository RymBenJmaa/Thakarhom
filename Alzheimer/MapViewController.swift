//
//  MapViewController.swift
//  Alzheimer
//
//  Created by Rym Ben Jmaa on 11/30/17.
//  Copyright © 2017 Esprit. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import StatusAlert
import CoreLocation
class MapViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mymapview: GMSMapView!
    var lat:Double = Double()
    var lon:Double = Double()
    var LocationManager = CLLocationManager()
    var locationStart = CLLocation(latitude: 36.898033, longitude: 10.189533)
    var locationEnd = CLLocation()
    override func viewWillAppear(_ animated: Bool) {
        
         if(!Connectivity.isConnectedToInternet()){
        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                  title: "You are off line",
                                                  message: "Please connect to a network")
        statusAlert.showInKeyWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            UIApplication.shared.open(URL(string: "App-Prefs:root=WIFI")!, options: [:], completionHandler: nil)
        }
         }else if(SharedData.role == "medecin") {
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "broken-heart"),
                                                      title: "Nothing to show",
                                                      message: "You don't have a patient you're a doctor")
            
            // Presenting created instance
            statusAlert.showInKeyWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                self.show(controller, sender: true)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(Connectivity.isConnectedToInternet()){
        if (!SharedData.AlzMail.isEmpty && SharedData.role == "assistant")
        { Alamofire.request(SharedData.URL+"getposition?email="+SharedData.AlzMail, method:.get).responseJSON{response in
            if(response.result.isSuccess)
            {
                self.mymapview.clear()
                let dict = response.result.value as? Dictionary<String,AnyObject>
                let groups = dict?["data"] as? NSArray
                self.lat = groups![0] as! Double
                self.lon = groups![1] as! Double
                self.locationEnd = CLLocation(latitude: self.lat, longitude: self.lon)
                self.LocationManager = CLLocationManager()
                self.LocationManager.delegate = self
                self.LocationManager.requestWhenInUseAuthorization()
                self.LocationManager.startUpdatingLocation()
                self.LocationManager.startMonitoringSignificantLocationChanges()
                if(self.LocationManager.location != nil)
                {self.locationStart = self.LocationManager.location!}
                self.initGoogleMpas()
                //36.898033
                //10,189533
                self.createMarker(titleMarker: "Your position",  latitude: self.locationStart.coordinate.latitude, icon: #imageLiteral(resourceName: "pin") , longitude: self.locationStart.coordinate.longitude)
                
                self.createMarker(titleMarker: "The patient",  latitude: (self.locationEnd.coordinate.latitude), icon: #imageLiteral(resourceName: "hpin"), longitude: (self.locationEnd.coordinate.longitude))
                self.drawPath(startLocation: self.locationStart, endLocation: self.locationEnd)
            }else if(response.result.isFailure){
                print("famech position!!")
            }
            }
        }else if(SharedData.role == "medecin") {
                let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "broken-heart"),
                                                          title: "Nothing to show",
                                                          message: "You don't have a patient you're a doctor")
                
                // Presenting created instance
                statusAlert.showInKeyWindow()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                    self.show(controller, sender: true)
                }
        }
        else
        {
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "broken-heart"),
                                                      title: "You're not logged in",
                                                      message: "Please login to see the position")
            
            // Presenting created instance
            statusAlert.showInKeyWindow()
           
        }
        
        }else{
            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                      title: "You are off line",
                                                      message: "Please connect to a network")
            statusAlert.showInKeyWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                UIApplication.shared.open(URL(string: "App-Prefs:root=WIFI")!, options: [:], completionHandler: nil)
            }
        }
     
        // Do any additional setup after loading the view.
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    if(Connectivity.isConnectedToInternet()){
                        
                        if (!SharedData.AlzMail.isEmpty && SharedData.role == "assistant")
                        { Alamofire.request(SharedData.URL+"getposition?email="+SharedData.AlzMail, method:.get).responseJSON{response in
                            if(response.result.isSuccess)
                            {
                                self.mymapview.clear()
                                let dict = response.result.value as? Dictionary<String,AnyObject>
                                let groups = dict?["data"] as? NSArray
                                self.lat = groups![0] as! Double
                                self.lon = groups![1] as! Double
                                self.locationEnd = CLLocation(latitude: self.lat, longitude: self.lon)
                                self.locationStart = self.LocationManager.location!
                                self.initGoogleMpas()
                                //36.898033
                                //10,189533
                                self.createMarker(titleMarker: "Your position",  latitude: self.locationStart.coordinate.latitude, icon: #imageLiteral(resourceName: "pin") , longitude: self.locationStart.coordinate.longitude)
                                
                                self.createMarker(titleMarker: "The patient",  latitude: (self.locationEnd.coordinate.latitude), icon: #imageLiteral(resourceName: "hpin"), longitude: (self.locationEnd.coordinate.longitude))
                                self.drawPath(startLocation: self.locationStart, endLocation: self.locationEnd)
                            }else if(response.result.isFailure){
                                print("famech position!!")
                            }
                            }
                        }else if(SharedData.role == "medecin") {
                            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "broken-heart"),
                                                                      title: "Nothing to show",
                                                                      message: "You don't have a patient you're a doctor")
                            
                            // Presenting created instance
                            statusAlert.showInKeyWindow()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nav")
                                self.show(controller, sender: true)
                            }
                        }
                        else
                        {
                            let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "broken-heart"),
                                                                      title: "You're not logged in",
                                                                      message: "Please login to see the position")
                            
                            // Presenting created instance
                            statusAlert.showInKeyWindow()
                            
                        }
                        
                    }else{
                        let statusAlert = StatusAlert.instantiate(withImage: UIImage(named: "warning"),
                                                                  title: "You are off line",
                                                                  message: "Please connect to a network")
                        statusAlert.showInKeyWindow()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                            UIApplication.shared.open(URL(string: "App-Prefs:root=WIFI")!, options: [:], completionHandler: nil)
                        }
                    }
                    
                }
            }
        }
    }
    func initGoogleMpas(){
        let camera = GMSCameraPosition.camera(withLatitude: locationStart.coordinate.latitude, longitude: locationStart.coordinate.longitude, zoom: 18.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.mymapview.camera = camera
        self.mymapview.delegate = self
        self.mymapview.isMyLocationEnabled = true
        self.mymapview.settings.myLocationButton = true
        
        // Creates a marker in the center of the map.
        
    }
    func createMarker(titleMarker: String,latitude: CLLocationDegrees,icon:UIImage, longitude: CLLocationDegrees    ){
        let Marker = GMSMarker()
        Marker.position = CLLocationCoordinate2DMake(latitude,longitude)
        Marker.title = titleMarker
        Marker.icon = icon
        Marker.map = mymapview
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error when get location")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        //        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        let locationTujuan = CLLocation(latitude: 37.784023631590777, longitude: -122.40486681461333)
        
        
        
        drawPath(startLocation: location!, endLocation: locationTujuan)
        
        //        self.googleMaps?.animate(to: camera)
        self.LocationManager.stopUpdatingLocation()
        
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mymapview.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mymapview.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mymapview.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mymapview.isMyLocationEnabled = true
        mymapview.selectedMarker = nil
        return false
    }
    
    
    
    //MARK: - this is function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = try? JSON(data: response.data!)
            
            let routes = json?["routes"].arrayValue
            
            // print route using Polyline
            for route in routes!
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.mymapview
            }
            
        }
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

