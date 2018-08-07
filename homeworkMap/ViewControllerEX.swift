

import UIKit
import MapKit
import CoreLocation
import CoreData

extension ViewController :MKMapViewDelegate , CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            assertionFailure("Invaild coordinate")
            return  }
        
        //        print("\(coordinate.latitude) \(coordinate.longitude)\n")  //好像會連續呼叫連3次
        location = coordinate   //更新
        pointArray.append(coordinate)
        
        
        ////////////////////////////////////////////////////////////////////////
        
        let urlString = "http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=cp101&UserName=jim&Lat=\(coordinate.latitude)&Lon=\(coordinate.longitude)"
        
        guard let url = URL(string : urlString) else {
            return assertionFailure("Invalid URl string.")
        }
        
        if ViewController.dataUpdateSwitchUse == true{      //更新位置
            
            mapView.add(MKPolyline(
                coordinates: pointArray, count: pointArray.count), level: .aboveRoads)
            //        加入MKOverlay 覆蓋物件 會觸發render for
            
            let downloader_update = Downloader(rssURL: url)
            downloader_update.download { (error, respone) in

                if let error = error {
                    print("Error:\(error)")
                    return
                }//Show alert to user.

            }
            /////////////////////////////////////////////////////////////
            // coredata
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            guard let context = appDelegate?.persistentContainer.viewContext else {
                return
            }
            
            let managedObjectModel = Friend(context: context)
            
//            managedObjectModel.id = ""
//            managedObjectModel.friendName = ""
            managedObjectModel.lat = "\(coordinate.latitude)"
            managedObjectModel.lon = "\(coordinate.longitude)"
//            managedObjectModel.lastUpdateDateTime = ""
            
            appDelegate?.saveContext()
        }//if
        
        
    }
    
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//        guard let annotation = annotation as? MKPointAnnotation else {
//            assertionFailure("Fail as MKAnnotation")
//            return nil //依照默認圖標
//        }
//
//        let identifier = "AnnotationView_id"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//
//        if annotationView == nil{
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//        }else{
//            annotationView?.annotation = annotation
//        }
//
//        return annotationView
//    }
    
    
    //    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    //
    //    }//可以讀取使用者更新的位置   我猜想這個更新是頻率 是沒有含之前設定的間隔 很頻繁
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {  //找到加入物件 開始對折線物件 算圖
            let overlayRenderer = MKPolylineRenderer(overlay: overlay)
            
            overlayRenderer.strokeColor = .blue
            overlayRenderer.lineWidth = 5
            
            mapView.remove(overlay)//繪製完成在地圖上清除 不清楚放的位置是否合適
            
            return overlayRenderer
        }
        //        return nil    無法回傳nil 求解
        return MKOverlayRenderer()
    }
    
}
