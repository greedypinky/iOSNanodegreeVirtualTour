//
//  PhotoSearchResponse.swif.swift
//  VirtualTour
//
//  Created by ritalaw on 2019-04-02.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import Foundation

/**
 { "photos": { "page": 1, "pages": "7892", "perpage": 100, "total": "789200",
 "photo": [
 { "id": "40558174193", "owner": "144775006@N04", "secret": "74ba85193a", "server": "7913", "farm": 8, "title": "-APOLLO-", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
 */


struct PhotoSearchResponse:Decodable {
    let page:String
    let pages:String
    let perpage:String
    let total:String
    let photos:[FlickrPhoto]
}

struct FlickrPhoto:Decodable {
    let id:String
    let owner:String
    let secret:String
    let server:String
    let farm:String
    let title:String
    let ispublic:String
    let isfriend:String
    let isfamily:String
}

