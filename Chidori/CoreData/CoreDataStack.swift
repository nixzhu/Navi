//
//  CoreDataStack.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import CoreData

class CoreDataStack {

    let model: NSManagedObjectModel
    let psc: NSPersistentStoreCoordinator
    let context: NSManagedObjectContext
    let store: NSPersistentStore?

    init() {

        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("Chidori", withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!

        psc = NSPersistentStoreCoordinator(managedObjectModel: model)

        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc

        let documentsURL = CoreDataStack.applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("Chidori")

        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true
        ]

        do {
            store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)

        } catch let error {
            print("Error adding persistent store: \(error)")
            abort()
        }
    }

    func saveContext() {

        if context.hasChanges {
            do {
                try context.save()
                print("normal")

            } catch let error as NSError {
                print("Could not save: \(error)")
            }
        }
    }

    class func applicationDocumentsDirectory() -> NSURL {

        let fileManager = NSFileManager.defaultManager()
        let URLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        return URLs[0]
    }
}

extension CoreDataStack {

    func users() -> [User]? {

        let request = NSFetchRequest(entityName: "User")

        do {
            if let users = try context.executeFetchRequest(request) as? [User] {
                return users
            }
        } catch let error as NSError {
            print(error)
        }

        return nil
    }
}

