
import Foundation

class VirtualTourClient {
    
    enum FlickrEndpoint {
        
        case getSearch(lat:Double,lon:Double)
        
        case getPhoto(id:String, secret:String, farmid:String, serverid:String)

        // computed string
        // use URLComponents to compose the component
        // method=flickr.photos.search
        // api_key=2c07d995ce5f68270fb0a9fcc3dfcfcb
        // lat=38.905351009168896
        // lon=-77.129282981547973
        // format=json
        // nojsoncallback=1
        // var in_gallery:Bool?=false
        // var per_page:Int?=100
        var stringValue:String {
            
            switch self {
                case let .getSearch(lat,lon):
                    // Hardcode the lat and lon for now
                    let api = FlickrAPI()
                    var urlComponents = api.getURLComponents()
                    // add params
                    let method = URLQueryItem(name: "method", value:api.methodName)
                    let apikey = URLQueryItem(name: "api_key", value: FlickrAPI.key) // let key = "b6717100c12e0bec49e0b9dcbec347fb"
                    let latitude = URLQueryItem(name: "lat", value: "\(lat)")
                    let longitude = URLQueryItem(name: "lon", value: "\(lon)")
                    let format = URLQueryItem(name: "format", value: "json")
                    let nojsoncallback = URLQueryItem(name: "nojsoncallback", value: "1")
                    let per_page = URLQueryItem(name: "per_page", value: "100")
                    urlComponents.queryItems = [method,apikey,latitude,longitude,format,nojsoncallback]
                    return urlComponents.url!.absoluteString
                    
//                    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=2c07d995ce5f68270fb0a9fcc3dfcfcb&lat=38.905351009168896&lon=-77.129282981547973&format=json&nojsoncallback=1&auth_token=72157677839136247-86cb0c61ef9355cd&api_sig=c37af41a57a1ce1d71c5cf1335b1ed5a"
                
                case let .getPhoto(id, secret, farmid, serverid):
                    // URL mapping https://www.flickr.com/services/api/misc.urls.html
                    // TODO: construct the source URL to a photo once you know its ID, server ID, farm ID and secret, as returned by many API methods.
                    return "https://farm\(farmid).staticflickr.com/\(serverid)/\(id)_\(secret).jpg"
            }
        }
        
        var url:URL {
            return URL(string:self.stringValue)!
        }
    }
    
 
    /**
     You must use the service "flickr.photos.search".
     https://www.flickr.com/services/api/flickr.photos.search.html
     var lat:String?
     var lon:String?
     var in_gallery:Bool?=false
     var per_page:Int?=100
    */
    class func photoGetRequest<RequestType:Encodable,ResponseType:Decodable>(photoSearch:RequestType, responseType: ResponseType.Type,completionHandler: @escaping (ResponseType?,Error?) -> Void) {
    
        let search = photoSearch as! PhotoSearch
        let endpoint:URL = FlickrEndpoint.getSearch(lat: search.lat, lon: search.lon).url
        print("Endpoint URL is \(endpoint)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
//        request.addValue(APIRequestKey.applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue(APIRequestKey.restapikey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let downloadTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // guard if there is data
            // otherwise return the alert error
            // first guard no error
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            // second guard we have data
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            // we have to decode the data
            let jsonDecoder = JSONDecoder()
            do {
              let decodedData = try jsonDecoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    // handle the decoded data
                    completionHandler(decodedData,nil)
                }
            } catch let decodeErr{
                DispatchQueue.main.async {
                    // handle the decoded data
                    print("what is the error? \(decodeErr.localizedDescription)")
                    completionHandler(nil, decodeErr)
                }
            }
        }
        
         // task from suspended state to start the task
         downloadTask.resume()
    }

    // Download the Image of the Photo
    // https://farm1.staticflickr.com/2/1418878_1e92283336_m.jpg
    class func photoImageDownload(url:URL,completionHandler: @escaping (Data?,Error?) -> Void) {
        
        let downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // guard there is no error
            guard error == nil else {
                completionHandler(nil,error)
                return
            }
            // guard we have image data
            guard let data = data else {
                completionHandler(nil,error)
                return
            }
            print("Photo URL has data!")
            completionHandler(data,nil)
        }
        
        // start the download task
        downloadTask.resume()
    }
    
    // can use this function for debug if Decode fails
    func parseJsonData(data: Data) throws -> [String: Any]? {
        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        return result
    }
    
    
    // TODO : we get the photo ID only
    // We still need to map the photo id to URL
    // Question so we should store the photo URL as string
    // NOT the actual image, we load the image when we load the collection.
    class func mapPhotoToURL(id:String, secret:String, farmid:String, serverid:String) -> URL {
        return FlickrEndpoint.getPhoto(id: id, secret: secret, farmid: farmid, serverid: serverid).url
    }
    
    
    
    
}
