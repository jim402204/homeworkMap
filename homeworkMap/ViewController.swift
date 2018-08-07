

import UIKit
import MapKit
import CoreLocation
import CoreData

//extension

//var friendsAnnotation : LocationInfo?


class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var pointArray=[CLLocationCoordinate2D]()
    var location : CLLocationCoordinate2D?
    
    static var dataUpdateSwitchUse = false  //切換開關
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func UpdateSwitchButton(_ sender: UISwitch) {
        ViewController.dataUpdateSwitchUse = !ViewController.dataUpdateSwitchUse
        //回報給server的開關
        print("\(ViewController.dataUpdateSwitchUse)")
        
        mapView.userTrackingMode = .follow
        
        guard let location = location else {
            return print("no location!!!!!!")
        }
        
        
        let span = MKCoordinateSpanMake(0.01 , 0.01)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true) //調整一開始的可視範圍（區域）
        
        if ViewController.dataUpdateSwitchUse == false {
            pointArray.removeAll()
        }
        
    }
    
    // 除了info屬性要設置外  apple 還要在手機設置中隱私訂位服務中 個別對所以app 去設置每個app開放權限 (手動)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()//詢問
        locationManager.allowsBackgroundLocationUpdates=true
        locationManager.pausesLocationUpdatesAutomatically=false //暫停回覆後
        
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            return
        }
        
        mapView.delegate = self
        locationManager.delegate = self
        
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 30
        locationManager.startUpdatingLocation()
        print("\n start")
        
        
        //urlconnect.url2.rawValue
        guard let url2 = URL(string : urlconnect.url2.rawValue) else {
            return assertionFailure("Invalid URl string.")
        }
        
        let downloader_Dfriends = Downloader(rssURL: url2) //要rename 前要先編譯
        downloader_Dfriends.download { (error, respone) in
            
            if let error = error {
                print("Error:\(error)")
                return
            }//Show alert to user.
            
            if let friends = respone {
                infoArray = friends
                
                for friendInfo in (infoArray?.friends)! {
//                    print("\(friendInfo)")
//                    print("\(String(describing: friendInfo.friendName))") //顯示有哪些朋友
                    if friendInfo.friendName == "jim"{ //移除自己的座標
                        continue
                    }
                    
                    guard let lat = Double(friendInfo.lat!) else {
                        print("\n\(friendInfo.friendName)")
                        return print("\(String(describing: friendInfo.lat))")
                    }
                    guard let lot = Double(friendInfo.lon!) else {
                        print("\n\(friendInfo.friendName)")
                        return print("\(String(describing: friendInfo.lon))")
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate =
                        CLLocationCoordinate2D(
                            latitude: lat, longitude: lot)
                    annotation.title = "ID:\(friendInfo.id!)  \(friendInfo.friendName!)"
                    annotation.subtitle = friendInfo.lastUpdateDateTime

                    DispatchQueue.main.asyncAfter(deadline:.now()) {
                        self.mapView.addAnnotation(annotation)
                    }
                }
                
            }else{
                //Show alert to user.
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let location = locationManager.location else {
            print("Location is  not ready")
            return
        }
        var coodinate = location.coordinate
        
        let span = MKCoordinateSpanMake(2 , 2)//5 5
        let region = MKCoordinateRegionMake(coodinate, span)
        mapView.setRegion(region, animated: true) //調整一開始的可視範圍（區域）
        
//        let annotation = MKPointAnnotation()      //test  用了客製化出問題
//        annotation.coordinate = CLLocationCoordinate2DMake(24.34, 121)
//        self.mapView.addAnnotation(annotation)
        
         print("\n end")

         //顯示歷史紀錄
        let request = NSFetchRequest<Friend>(entityName: "Friend")

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return
        }
            print("顯示歷史紀錄")
        do{
            let results = try context.fetch(request)

            for result in results {
                print("輸出\(String(describing: result.lat!))  \(String(describing: result.lon!))")
            }
//            print("\(results[0].id!)")
        }catch{
            print("\(error)")
        }
        
        ///////////////////////////////////////////////////////////
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


