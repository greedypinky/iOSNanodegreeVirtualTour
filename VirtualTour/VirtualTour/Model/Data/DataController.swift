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
    let backgroundContext:NSManagedObjectContext!

    // calculated variable
    var viewContext:NSManagedObjectContext {
        return persistenceContainer.viewContext
    }

    // modal name = "VirtualTour"
    init(modelName:String) {
        persistenceContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistenceContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
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

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}


