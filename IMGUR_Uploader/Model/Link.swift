//
//  Link.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 13.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import CoreData

public class Link : NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Link> {
        return NSFetchRequest<Link>(entityName: "Link")
    }
    
    @NSManaged public var link : String?
    
}
