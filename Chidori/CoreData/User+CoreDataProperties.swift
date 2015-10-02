//
//  User+CoreDataProperties.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var avatarURLString: String?
    @NSManaged var username: String?
    @NSManaged var userID: String?
    @NSManaged var createdUnixTime: NSNumber?
    @NSManaged var avatar: Avatar?
    @NSManaged var tweets: NSSet?

}
