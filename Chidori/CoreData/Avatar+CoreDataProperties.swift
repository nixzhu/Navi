//
//  Avatar+CoreDataProperties.swift
//  Chidori
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Avatar {

    @NSManaged var avatarData: NSData?
    @NSManaged var avatarURLString: String?
    @NSManaged var miniAvatarData: NSData?
    @NSManaged var nanoAvatarData: NSData?
    @NSManaged var user: User?

}
