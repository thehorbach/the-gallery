//
//  Art+CoreDataProperties.swift
//  TheGallery
//
//  Created by Vyacheslav Horbach on 16/10/16.
//  Copyright © 2016 Homework Tutor LTD. All rights reserved.
//

import Foundation
import CoreData


extension Art {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Art> {
        return NSFetchRequest<Art>(entityName: "Art");
    }

    @NSManaged public var title: String?
    @NSManaged public var imageName: String?
    @NSManaged public var purchased: Bool
    @NSManaged public var productIdentifier: String?

}
