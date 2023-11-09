//
//  mapViewController.swift
//  hw4
//
//  Created by Chloe Nguyen on 10/17/23.
//

import UIKit
import CoreLocation
import MapKit
import Network
import Foundation

struct LocationData: Codable {
    let type: String
    let features: [Feature]
    
    struct Feature: Codable {
        let type: String
        let properties: Properties
        let geometry: Geometry
    }
    
    struct Properties: Codable {
        let zipCode: String
        let country: String
        let city: String
        let county: String
        let state: String
    }

    struct Geometry: Codable {
        let type: String
        let coordinates: [[[Double]]]  // coordinates is an array of arrays of doubles
    }
}

class mapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var zipcode: UILabel!
    var zip: String = "10027"
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var locationDataArray = [LocationData]()
    var coordinateArray: [(Double, Double)] = []
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if coordinateArray.isEmpty {
//            fetchLocationData(latitude: 40.809701, longitude: -73.963539)
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                print("There is internet connection")
            } else {
                DispatchQueue.main.async {
                    self.showNoInternetAlert()
                }
                print("There is no internet connection")
            }
        }
        self.zipcode.text = self.zip
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            mapView.addGestureRecognizer(tapGesture)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let barnard = CLLocationCoordinate2D(latitude: 40.809701, longitude: -73.963539)
        let initialRegion = MKCoordinateRegion(center: barnard, span: span)
        mapView.setRegion(initialRegion, animated: true)
        let barnardCoords = [CLLocationCoordinate2D(latitude: 40.810755, longitude: -73.964424),
                             CLLocationCoordinate2D(latitude: 40.810373, longitude: -73.963477),
                             CLLocationCoordinate2D(latitude: 40.810947, longitude: -73.963058),
                             CLLocationCoordinate2D(latitude: 40.811331, longitude: -73.964019),
                             CLLocationCoordinate2D(latitude: 40.815146, longitude: -73.961398),
                             CLLocationCoordinate2D(latitude: 40.816607, longitude: -73.961276),
                             CLLocationCoordinate2D(latitude: 40.817511, longitude: -73.960687),
                             CLLocationCoordinate2D(latitude: 40.818099, longitude: -73.962067),
                             CLLocationCoordinate2D(latitude: 40.818512, longitude: -73.96298),
                             CLLocationCoordinate2D(latitude: 40.820422, longitude: -73.960007),
                             CLLocationCoordinate2D(latitude: 40.817221, longitude: -73.952273),
                             CLLocationCoordinate2D(latitude: 40.817922, longitude: -73.949734),
                             CLLocationCoordinate2D(latitude: 40.820301, longitude: -73.947552),
                             CLLocationCoordinate2D(latitude: 40.822108, longitude: -73.948083),
                             CLLocationCoordinate2D(latitude: 40.821264, longitude: -73.946078),
                             CLLocationCoordinate2D(latitude: 40.815692, longitude: -73.948677),
                             CLLocationCoordinate2D(latitude: 40.812815, longitude: -73.941803),
                             CLLocationCoordinate2D(latitude: 40.81063, longitude: -73.943398),
                             CLLocationCoordinate2D(latitude: 40.808958, longitude: -73.940404),
                             CLLocationCoordinate2D(latitude: 40.807089, longitude: -73.941771),
                             CLLocationCoordinate2D(latitude: 40.806391, longitude: -73.944302),
                             CLLocationCoordinate2D(latitude: 40.803877, longitude: -73.946131),
                             CLLocationCoordinate2D(latitude: 40.80313, longitude: -73.944667),
                             CLLocationCoordinate2D(latitude: 40.806981, longitude: -73.9535),
                             CLLocationCoordinate2D(latitude: 40.807546, longitude: -73.956806),
                             CLLocationCoordinate2D(latitude: 40.810064, longitude: -73.954966),
                             CLLocationCoordinate2D(latitude: 40.811264, longitude: -73.957808),
                             CLLocationCoordinate2D(latitude: 40.81008, longitude: -73.957091),
                             CLLocationCoordinate2D(latitude: 40.805435, longitude: -73.959826),
                             CLLocationCoordinate2D(latitude: 40.805509, longitude: -73.962008),
                             CLLocationCoordinate2D(latitude: 40.806707, longitude: -73.964848),
                             CLLocationCoordinate2D(latitude: 40.808004, longitude: -73.963903),
                             CLLocationCoordinate2D(latitude: 40.808806, longitude: -73.9659),
                             CLLocationCoordinate2D(latitude: 40.810755, longitude: -73.964424)]
        
        
        let polyline = MKPolyline(coordinates: barnardCoords, count: barnardCoords.count)
        let polygon = MKPolygon(coordinates: barnardCoords, count: barnardCoords.count)
        
        mapView.addOverlay(polyline)
        mapView.addOverlay(polygon)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
           
            // Get the point where the user tapped on the map
            let locationInView = gesture.location(in: mapView)
            
            // Convert the tap point to a CLLocationCoordinate2D
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            coordinateArray.removeAll()
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)

            
            // Pass the coordinates to the fetchLocationData function
            fetchLocationData(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
//            let newRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//            mapView.setRegion(newRegion, animated: true)
            
            // Update the map view or perform other actions based on the selected location
            // For example, you can add an annotation to mark the selected location.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func fetchLocationData(latitude: Double, longitude: Double) {
        let headers = [
            "X-RapidAPI-Key": "",
            "X-RapidAPI-Host": "vanitysoft-boundaries-io-v1.p.rapidapi.com"
        ]
        
        let urlString = "https://vanitysoft-boundaries-io-v1.p.rapidapi.com/reaperfire/rest/v1/public/boundary/zipcode/within?latitude=\(latitude)&longitude=\(longitude)&showwithinpoint=1"
        
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)

        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            }
            guard let jsonData = data else {
                print("No data")
                return
            }
            
            do {
                let data = try JSONDecoder().decode(LocationData.self, from: jsonData)
                self.locationDataArray.append(data)
                // print here
//                print("Location: \(data.features)")
                for feature in data.features {
                    self.zip = feature.properties.zipCode
                    let geometry = feature.geometry
                    let coordinates = geometry.coordinates
                    for coordinate in coordinates {
                        for point in coordinate{
                            if point.count >= 2 {
                                let longitude = point[0]
                                let latitude = point[1]
//                                print("Longitude: \(longitude), Latitude: \(latitude)")
                                self.coordinateArray.append((latitude, longitude))
                            }
                        }
                    }
                }
//                print(self.coordinateArray)
                DispatchQueue.main.async {
                    self.renderMapOverlay(latitude: latitude, longitude: longitude)
                }
                print("Done!")
                
            } catch {
                print("JSON Decode error: \(error)")
            }
        })
        
//        print(self.coordinateArray)
        dataTask.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: CoreLocation Delegate methods
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("App is authorized")
            locationManager.startUpdatingLocation()
        }
        
        if status == .notDetermined || status == .denied {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
        //print("Location \(locations.first)")
        print("Latitude = \(locations.first!.coordinate.latitude)")
        print("Longitude = \(locations.first!.coordinate.longitude)")
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Mapkit Overlay
        
    func renderMapOverlay(latitude: Double, longitude: Double) {
        /* Add Mapkit features
         1. import MapKit
         2. add protocol MKMapViewDelegate to class:
         // class locationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate  {
         3. Connect IBOutlet to mapView on storyboard.
         4. set mapView.delegate
         5. implement mapView renderer delegate method
         */
        print(self.coordinateArray)
        self.zipcode.text = self.zip
//        let muddCoords = CLLocationCoordinate2D(latitude: 40.809701, longitude: -73.963539)
        let currCoords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
//        let region = MKCoordinateRegion(center: muddCoords, span: span)
        let region = MKCoordinateRegion(center: currCoords, span: span)

        mapView.setRegion(region, animated: true)

//        let annotationMudd = MKPointAnnotation()
//        annotationMudd.coordinate = muddCoords
//        annotationMudd.title = "Milstein Library"
//        annotationMudd.subtitle = "Barnard College"
//        mapView.addAnnotation(annotationMudd)
        
//        let annotationCoord = MKPointAnnotation()
//        annotationCoord.coordinate = currCoords
//        annotationCoord.title = "Milstein Library"
//        annotationCoord.subtitle = "Barnard College"
//        mapView.addAnnotation(annotationCoord)

//        let columbiaCampusCorners = [
//            CLLocationCoordinate2D(latitude: 40.810818, longitude: -73.963041),
//            CLLocationCoordinate2D(latitude: 40.810522, longitude: -73.962331),
//            CLLocationCoordinate2D(latitude: 40.808202, longitude: -73.964036),
//            CLLocationCoordinate2D(latitude: 40.808495, longitude: -73.964735),
//            CLLocationCoordinate2D(latitude: 40.810818, longitude: -73.963041),
//        ]
        var coordCorners: [CLLocationCoordinate2D] = []

        for coordTuple in self.coordinateArray {
            let coord = CLLocationCoordinate2D(latitude: coordTuple.0, longitude: coordTuple.1)
            coordCorners.append(coord)
        }
        
//        let polyline = MKPolyline(coordinates: columbiaCampusCorners, count: columbiaCampusCorners.count)
//        let polygon = MKPolygon(coordinates: columbiaCampusCorners, count: columbiaCampusCorners.count)
        
        print(coordCorners)
        
        let polyline = MKPolyline(coordinates: coordCorners, count: coordCorners.count)
        let polygon = MKPolygon(coordinates: coordCorners, count: coordCorners.count)
        
        mapView.addOverlay(polyline)
        mapView.addOverlay(polygon)
    
    }
    
    
    //MARK: Mapkit Delegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemPink.withAlphaComponent(0.8)
            renderer.lineWidth = 3
            return renderer
        }

        if let rectPolygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: rectPolygon)
            renderer.fillColor = UIColor.systemPink.withAlphaComponent(0.1)
//            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
            return renderer
        }

        return MKOverlayRenderer()
    }




}
