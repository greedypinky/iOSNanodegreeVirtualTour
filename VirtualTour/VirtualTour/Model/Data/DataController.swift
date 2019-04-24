//
//  DataController.swift
//  VirtualTour
//
//  Created by Man Wai  Law on 2019-04-14.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import Foundation
import CoreData

class DataController {

    let persistenceContainer:NSPersistentContainer

    // calculated variable
    var viewContext:NSManagedObjectContext {
        return persistenceContainer.viewContext
    }

    // modal name = "VirtualTour"
    init(modelName:String) {
        persistenceContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        
        persistenceContainer.loadPersistentStores { (storeDescription, error) in
            
              //
            guard error == nil else {
                fatalError(error!.localizedDescription)
                
            }
            completion?()
        }
    }

}


