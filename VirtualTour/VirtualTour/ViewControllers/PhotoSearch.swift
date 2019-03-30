//
//  PhotoSearch.swift
//  VirtualTour
//
//  Created by ritalaw on 2019-03-29.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import Foundation

struct photoSearch:Codable {
    
    var lat:String?
    var lon:String?
    var in_gallery:Bool?=false
    var per_page:Int?=100
    
//    lat (Optional)
//    A valid latitude, in decimal format, for doing radial geo queries.
//
//    Geo queries require some sort of limiting agent in order to prevent the database from crying. This is basically like the check against "parameterless searches" for queries without a geo component.
    
//    A tag, for instance, is considered a limiting agent as are user defined min_date_taken and min_date_upload parameters — If no limiting factor is passed we return only photos added in the last 12 hours (though we may extend the limit in the future).
    
//    lon (Optional)
//    A valid longitude, in decimal format, for doing radial geo queries.

    
    
    
}
