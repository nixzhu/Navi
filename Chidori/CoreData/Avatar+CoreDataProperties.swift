//
//  Avatar+CoreDataProperties.swift
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

extension Avatar {

    @NSManaged var avatarURLString: String?
    @NSManaged var miniRoundAvatarData: NSData?
    @NSManaged var miniSquareAvatarData: NSData?
    @NSManaged var originalAvatarData: NSData?
    @NSManaged var user: User?

}
