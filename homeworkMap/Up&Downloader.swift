
import Foundation

struct LocationInfo : Codable {
    var result:Bool = false
    var errorCode :String? = ""
    var friends : [friendIn]?
    //    enum CodingKeys: String ,Bool, CodingKey {       //指定屬性編碼
    //        case result
    //        case errorCode
    //        case friends
    //    }
    struct friendIn : Codable{
        var id :String? = ""
        var friendName :String? = ""
        var lat :String? = ""
        var lon :String? = ""
        var lastUpdateDateTime :String? = ""
        
        enum CodingKeys2: String, CodingKey {       //指定屬性編碼
            case id
            case friendName
            case lat
            case lon
            case lastUpdateDateTime
        }
    }
}


var infoArray :LocationInfo?

enum urlconnect : String{
    case url1="http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=cp101&UserName=jim&Lat="
    case url2="http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=cp101"
}

typealias DownloadHandler = (Error? , LocationInfo?) -> Void
//alias 暱稱

class Downloader {
    
    static var infoArray = LocationInfo()
    
    let targetURL:URL
    init(rssURL:URL) {
        targetURL = rssURL
    } //類別內 常數可以延後給初始化。fun裡面用法不一樣
    
    func download (doneHandler: @escaping DownloadHandler ) {
        //這是model 就算是錯誤訊息也該回傳給 control 來顯示
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: targetURL) { (data, respone, error) in
            
            if let error = error {
                print("Download Fail:\(error)")
                DispatchQueue.main.async { //確保後面的人下載不會用問題
                    doneHandler(error,nil)// 有任何變數從參數傳進來 會先丟進stack
                }
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                let error = NSError(domain: "Data is nil", code: -1, userInfo: nil)//錯誤代碼多為負的
                //userInfo: nil後面也可在夾帶資訊
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                return
            }
            
            let dataString = String(data: data, encoding: .utf8)!
//            print("\n\n\n\(dataString)")

            let decoder = JSONDecoder()
            
            var results:LocationInfo?
            do{
                results = try decoder.decode(LocationInfo.self, from: data)
                //let results = try? decoder.decode(LocationInfo.self, from: data)
            }catch{
                print("\(error)")
            }
            
            guard let result = results ,result.result == true else{//第一關 有true
                //Parse Fail
                let error = NSError(domain: "Parse json Fail result", code: -1, userInfo: nil)
                
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                return print("parse json error1 \n\(String(describing: results?.errorCode))\n")
            }
            print("連線成功")
            
            guard let friends = results?.friends else {//第二關    有friends array
//                let error = NSError(domain: "Parse json Fail friends", code: -1, userInfo: nil)
//
//                DispatchQueue.main.async {
//                    doneHandler(error,nil)
//                }
//                print("parse json error2 \n\(String(describing: results?.errorCode))\n")
                return
            }
            //Parse OK
            DispatchQueue.main.async {
                doneHandler(nil,results)
            }
            
            print("下載其他朋友座標成功")
//            print("  \n\(String(describing: result.friends![0].id!))")
//            print("  \(String(describing: result.friends![0].friendName!))")
//            print("  \(String(describing: result.friends![0].lat!))")
//            print("  \(String(describing: result.friends![0].lon!))")
//            print("  \(String(describing: result.friends![0].lastUpdateDateTime!))\n")
            
        }
        task.resume()
    }
    //手勢 一直加會會很延遲   ios中有add 的方法 都會有多開的風險 記得
}
