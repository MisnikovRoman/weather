//
//  ViewController.swift
//  WeatherApp
//
//  Created by Роман Мисников on 16.03.2018.
//  Copyright © 2018 Роман Мисников. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var citySearchBar: UISearchBar!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    @IBOutlet weak var fellsTempLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var updateLocationButton: UIButton!
    @IBOutlet weak var debugLabel: UILabel!
    
    // create location manager to use geolocation
    let locationManager = CLLocationManager()
    
    // MARK: - MAIN viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        citySearchBar.delegate = self
        
        startLocationManager()
    }

    //============================================================================
    
    // MARK: - Alert
    func simpleAlert (title: String, message: String, buttonText: String) {
        // Create controller for alert message
        // preferredStyle: .alert (сообщение по центру) или .actionSheet (сообщение снизу)
        let simpleAlertController = UIAlertController(title: title,
                                                      message: message,
                                                      preferredStyle: .alert)
        // Create button in alert message
        let action = UIAlertAction(title: buttonText, style: .cancel) { (action) in
            // This code will work after button "Согласен" will be pressed
        }
        // Add action to controller
        simpleAlertController.addAction(action)
        // Show alert message after button press
        self.present(simpleAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Inicialization of location manager
    func startLocationManager() {
        // ask user for permission
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            // use delegate to update position
            locationManager.delegate = self
            // set accuracy of location
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            // ask for one time location
            //locationManager.requestLocation()
            
        }
    }

    @IBAction func updateLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
    
}

// MARK: - Delegate search bar functions
// add delegate to search bar
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // hide keyboard
        citySearchBar.resignFirstResponder()
        
        // check data in searchBar
        if let inputText = searchBar.text {
            //debugLabel.text = inputText
            if inputText == "" {
                simpleAlert(title: "Внимание", message: "Для получения информации о погоде необходимо корректно заполнить поле поиска", buttonText: "ОК")
            }
        } else {
            simpleAlert(title: "Внимание", message: "Для получения информации о погоде необходимо корректно заполнить поле поиска", buttonText: "ОК")
        }
        
        var locationName: String?
        var temperature: Int?
        var minTemperature: Int?
        var maxTemperature: Int?
        var feelsLikeTemperature: Int?
        var errorHasOccured: Bool = false
        var errorName: String?
        var lastUpdated: String?
        var weatherCondition: String?
        var windSpeed: Double?
        var humidity: Int?
        
        
        // get url site apixu.com after registration
        // and delete all spaces from url
        //let stringUrl = "https://api.apixu.com/v1/current.json?key=4a0e82f6fc6f4f6e9d573424181603&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))"
        let stringUrl = "https://api.apixu.com/v1/forecast.json?key=4a0e82f6fc6f4f6e9d573424181603&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))&days=1"
        // try to make url from string
        print(stringUrl)
        if let url = URL(string: stringUrl) {
        
            // create new task with url and response
            let task = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                
                    // if we enter wrong city name and send it to server
                    if let errorMessage = json["error"] {
                        errorHasOccured = true
                        errorName = errorMessage["message"] as? String
                    }
                    
                    // try to get location dictionary from json code
                    if let location = json["location"] {
                        // take parameter from dictionary and set it type to String
                        locationName = location["name"] as? String
                    }
                    
                    // try to get current weather
                    if let current = json["current"] {
                        // take parameter from dictionary and set it type to Int
                        if let temperatureDouble = current["temp_c"] as? Double {
                            temperature = Int(temperatureDouble)
                        }
                        if let feelTempDouble = current["feelslike_c"] as? Double {
                            feelsLikeTemperature = Int(feelTempDouble)
                        }
                        lastUpdated = current["last_updated"] as? String
                        if let weatherConditionDict = current["condition"] as? [String: Any] {
                            weatherCondition = weatherConditionDict["text"] as? String
                        }
                        humidity = current["humidity"] as? Int
                        windSpeed = current["wind_kph"] as? Double
                    }
                    
                    
                    if let forecast = json["forecast"] as? [String: AnyObject] {
                        if let forecastDay = forecast["forecastday"] as? [AnyObject] {
                            if let firstDay = forecastDay[0] as? [String: AnyObject] {
                                if let day = firstDay["day"] as? [String: AnyObject] {
                                    if let minTempDouble = day["mintemp_c"] as? Double {
                                        minTemperature = Int(minTempDouble)
                                    }
                                    if let maxTempDouble = day["maxtemp_c"] as? Double {
                                        maxTemperature = Int(maxTempDouble)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Для выполнения действий с UI в главном потоке
                    DispatchQueue.main.async {
                        if errorHasOccured {
                            self?.simpleAlert(title: "Ошибка", message: errorName!, buttonText: "ОК")
                        } else {
                            self?.cityLabel.text = locationName
                            //self?.temperatureLabel.text = "\(feelsLikeTemperature!) (\(temperature!))"
                            self?.temperatureLabel.text = "\(temperature!)"
                            self?.minTempLabel.text = "\(minTemperature!)"
                            self?.maxTempLabel.text = "\(maxTemperature!)"
                            self?.conditionsLabel.text = weatherCondition
                            self?.lastUpdatedLabel.text = lastUpdated
                            
                            self?.fellsTempLabel.text = "\(feelsLikeTemperature!)ºC"
                            self?.windLabel.text = "\(windSpeed!)m/s"
                            self?.humidityLabel.text = "\(humidity!)%"
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
            // start our task
            task.resume()
        } else {
            // can not create URL from string
            simpleAlert(title: "Внимание", message: "Невозможно создать ссылку с введенным с поле поиска текстом", buttonText: "ОК")
        }
    }
}

// MARK: - Location Delegate methods
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        debugLabel.text = "locations = \(locValue.latitude) \(locValue.longitude)"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


