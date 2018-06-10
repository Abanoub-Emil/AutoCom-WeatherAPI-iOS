//
//  ViewController.swift
//  InovaTask
//
//  Created by Champion on 5/20/18.
//  Copyright © 2018 ITI. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import MapKit
import GoogleMaps
import Alamofire
import SwiftyJSON
class ViewController: UIViewController {
    var longit:Double?
    var latit:Double?
    var temp = Float()
    var placesClient: GMSPlacesClient!
    var annot=Annotation()
    @IBOutlet weak var myMap: MKMapView!
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
    }
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })
    }
    
    @IBAction func pickPlace(_ sender: UIButton) {
        let center = CLLocationCoordinate2D(latitude: 30.788204, longitude: 29.411937)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.nameLabel.text = place.name
                self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                    .joined(separator: "\n")
               self.latit =  place.coordinate.latitude
                print(self.latit!)
                self.longit = place.coordinate.longitude
                print(self.longit!)
                self.annot.coordinate.latitude=self.latit!
                self.annot.coordinate.longitude=self.longit!
                self.annot.title=place.name
                
                self.requestWeather(placeID: place.name)
            } else {
               self.nameLabel.text = "No place selected"
                self.addressLabel.text = ""
            }
        })
    }

    
    func requestWeather(placeID:String){
        let lon:String = String(format:"%f",longit! )
        let lat:String = String(format:"%f",latit! )
        print("\(lon)   \(lat)")
        let url = URL(string:"http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=e84116b92a25de003407e11edddb6708")

        let request = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)

        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in

            let json = try? JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! NSDictionary
            print(json!)
            let info = json?.object(forKey: "main") as! NSDictionary
            let temprature = info.object(forKey: "temp")
            print(temprature!)
            self.annot.subtitle="\(String(describing: temprature!))  Fehrenhait"
            self.myMap.addAnnotation(self.annot)
        })
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

