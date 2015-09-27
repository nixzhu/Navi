//
//  User+Avatar.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import CoreData
import Navi

extension User: Navi.Avatar {

    var name: String {
        return username!
    }

    var URL: NSURL {
        return NSURL(string: avatarURLString!)!
    }

    var style: AvatarStyle {
        return .Rectangle(size: CGSize(width: 40, height: 40))
    }

    var localImage: UIImage? {

        if let avatar = avatar, data = avatar.avatarData {
            return UIImage(data: data)
        }

        return nil
    }

    func saveOriginalImage(image: UIImage) {

        let coreDataStack = CoreDataStack()

        let context = coreDataStack.context

        let avatarEntityDescription = NSEntityDescription.entityForName("Avatar", inManagedObjectContext: context)!
        let avatar = NSManagedObject(entity: avatarEntityDescription, insertIntoManagedObjectContext: context) as! Avatar

        avatar.avatarURLString = URL.absoluteString
        avatar.avatarData = UIImageJPEGRepresentation(image, 1.0)
        // TODO

        let fetchUserRequest = NSFetchRequest(entityName: "User")

        fetchUserRequest.predicate = NSPredicate(format: "avatarURLString = %@", URL.absoluteString)

        do {
            if let users = try context.executeFetchRequest(fetchUserRequest) as? [User] {
                avatar.user = users.first
            }

        } catch let error as NSError {
            print(error)
        }

        coreDataStack.saveContext()
    }
}
