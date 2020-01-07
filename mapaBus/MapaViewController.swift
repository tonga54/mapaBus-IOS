//
//  MapaViewController.swift
//  mapaBus
//
//  Created by Gaston Rodriguez Agriel on 12/15/19.
//  Copyright © 2019 Gaston Rodriguez Agriel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapaViewController: UIViewController {
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var mapa: MKMapView!
    let locationManager = CLLocationManager()
    var timer : Timer? = nil
    let regionInMeters: Double = 3000
    var linea : String = ""
    let alert = UIAlertController(title: nil, message: "Cargando los buses", preferredStyle: .alert)
    let alertaUbicacion = UIAlertController(title: "Ubicacion", message: "Activa la localizacion para una mejor experiencia.", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ALERTA CARGANDO
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
///
        self.getBuses()
        self.timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { timer in
            self.getBuses()
        }
        checkLocationServices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer!.invalidate()
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUSerLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapa.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }else{
//            self.alertaUbicacion.addAction(UIAlertAction(title: "Ir a configuracion", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
//                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
//            }))
//            alertaUbicacion.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
//                self.alertaUbicacion.dismiss(animated: true, completion: nil)
//            }))
//            present(self.alertaUbicacion, animated: true, completion: nil)
            
            let center = CLLocationCoordinate2D(latitude: -34.895161, longitude: -56.164727)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapa.setRegion(region, animated: true)
            
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Do map stuff
            mapa.showsUserLocation = true
            centerViewOnUSerLocation()
            locationManager.startUpdatingLocation()
            break;
        case .denied:
            // Show alert instructing them how to turn on permissions
            break;
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break;
        case .restricted:
            // Show an alert letting them know whats up
            break;
        case .authorizedAlways:
            mapa.showsUserLocation = true
            centerViewOnUSerLocation()
            locationManager.startUpdatingLocation()
            break;
        default:
            break;
        }
    }
    
    
    
    func getBuses(){
        
        var buses : Array<BusModel> = []
        let endpoint: String = "http://www.montevideo.gub.uy/buses/rest/stm-online"
        let url = URL(string: endpoint)
        var urlRequest = URLRequest(url: url!);
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let busData : [String: Any] = ["lineas" : [self.linea]]
        let jsonData: Data
        var responseData : Data? = nil
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: busData, options: [])
            urlRequest.httpBody = jsonData
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("Error al realizar la peticion", error!.localizedDescription)
            }
            else{
                responseData = data!
            }
            
            
            do {
                let datosParseados = try JSONSerialization.jsonObject(with: responseData!, options: []) as? [String: Any]
                let jsonArray = datosParseados!["features"] as? [[String: Any]]
                
                DispatchQueue.main.async {
                   // Update UI
                    
                    
                    //Cerrar alerta cargando
                    self.alert.dismiss(animated: true, completion: nil)
                   
                    
    //                REMUEVO LAS ANOTACIONES DE LOS BUSES
                    let annotations = self.mapa.annotations
                    self.mapa.removeAnnotations(annotations)
                    
                    for item in jsonArray! {
                        let properties = item["properties"] as AnyObject
                        let subLinea = properties["sublinea"] as! String
                        let coordenadas = ((item["geometry"]! as AnyObject)["coordinates"] as Any) as! Array<Double>
                        let busModel = BusModel(lat: coordenadas[1], lng: coordenadas[0], subLinea: subLinea)
                        self.agregarMarcadorBus(bus: busModel)
                        buses.append(busModel)
                    }
                }
                
                
                
            } catch  {
                print("error parsing response from POST on /todos")
                return
            }
        })
        
        task.resume()
    }
    
    
    func agregarMarcadorBus(bus:BusModel){
        let mark = MKPointAnnotation()
        mark.title = String(bus.subLinea)
        mark.coordinate = CLLocationCoordinate2D(latitude: bus.lat, longitude: bus.lng)
        self.mapa.addAnnotation(mark)
    }
    
}

//ACTUALIZA EL PIN DE LA LOCALIZACION
extension MapaViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // ME LLEVA HASTA LA LOCALIZACION ACTUAL
        
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapa.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        checkLocationAuthorization()
    }
    
}
