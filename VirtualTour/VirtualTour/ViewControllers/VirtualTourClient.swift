
import Foundation

class VirtualTourClient {
    
    enum FlickrEndpoint {
        
        case getSearch()
        
        case getPhoto(id:String, secret:String, farmid:String, serverid:String)

        // computed string
        // use URLComponents to compose the component
        // method=flickr.photos.search
        // api_key=2c07d995ce5f68270fb0a9fcc3dfcfcb
        // lat=38.905351009168896
        // lon=-77.129282981547973
        // format=json
        // nojsoncallback=1
        // auth_token=72157677839136247-86cb0c61ef9355cd
        // api_sig=c37af41a57a1ce1d71c5cf1335b1ed5a
        var stringValue:String {
            
            switch self {
                case .getSearch:
                    // Hardcode the lat and lon for now
                    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=2c07d995ce5f68270fb0a9fcc3dfcfcb&lat=38.905351009168896&lon=-77.129282981547973&format=json&nojsoncallback=1&auth_token=72157677839136247-86cb0c61ef9355cd&api_sig=c37af41a57a1ce1d71c5cf1335b1ed5a"
                        // return "https://api.flickr.com/services/rest"
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
    
    /*
     // the API KEY not working
  https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=b6717100c12e0bec49e0b9dcbec347fb&lat=38.905351009168896&lon=-77.129282981547973&format=json&nojsoncallback=1&auth_token=72157677823070977-abe0198bf0dbe663&api_sig=23177536977d8dddd3554bc446f1572a
     // This one is working
    https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=2c07d995ce5f68270fb0a9fcc3dfcfcb&lat=38.905351009168896&lon=-77.129282981547973&format=json&nojsoncallback=1&auth_token=72157677839136247-86cb0c61ef9355cd&api_sig=c37af41a57a1ce1d71c5cf1335b1ed5a
 */
    /**
     You must use the service "flickr.photos.search".
     https://www.flickr.com/services/api/flickr.photos.search.html
     var lat:String?
     var lon:String?
     var in_gallery:Bool?=false
     var per_page:Int?=100
    */
    class func photoGetRequest<RequestType:Encodable,ResponseType:Decodable>(photoSearch:RequestType, responseType: ResponseType.Type,completionHandler: @escaping (ResponseType?,Error?) -> Void) {
            // add
        
        let endpoint:URL = FlickrEndpoint.getSearch().url
        print("Endpoint URL is \(endpoint)")
        let request = URLRequest(url: endpoint)
        
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
            
            // MARK: DEBUG ==============================

            do {
                    let jsonSerial =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
    
//                   let createdAt = jsonSerial["createdAt"] as! String
//
//                   let objectId = jsonSerial["objectId"] as! String
//
//                    print("created at \(createdAt) objectId: \(objectId)" )
    
                } catch {
                    print(error)
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
                    completionHandler(nil, decodeErr)
                }
            }
        }
        
         // task from suspended state to start the task
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
