
import Foundation

class VirtualTourClient {
    
    enum FlickrEndpoint{
        
        case getSearch()

        // computed string
        var stringValue:String {
            
            switch self {
            case .getSearch:
                    return "https://api.flickr.com/services/rest"
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
     var per_page:Int?=100 lat:String?
    */
    func photoGetRequest<RequestType:Encodable,ResponseType:Decodable>(photoSearch:RequestType, responseType: ResponseType.Type,completionHandler: @escaping (ResponseType?,Error?) -> Void) {
            // add
        
        let endpoint:URL = FlickrEndpoint.getSearch().url
        var request = URLRequest(url: endpoint)
        
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
                    completionHandler(nil, decodeErr)
                }
            }
        }
    }

    
}
