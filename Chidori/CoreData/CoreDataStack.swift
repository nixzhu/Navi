//
//  CoreDataStack.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

    func trySave() {

        if hasChanges {
            do {
                try save()
                print("save success")

            } catch let error as NSError {
                print("Error: could not save: \(error)")
            }
        }
    }
}

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
            print("Error: adding persistent store: \(error)")
            abort()
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
        let sortDescriptor = NSSortDescriptor(key: "username", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
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

