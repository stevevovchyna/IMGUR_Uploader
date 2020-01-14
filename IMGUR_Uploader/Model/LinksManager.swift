//
//  LinksManager.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 13.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import CoreData

public class LinkManager : NSObject {
    
    var context : NSManagedObjectContext
    
    public override init() {
        let bundle = Bundle(identifier: "com.stevevovchyna.IMGUR-Uploader")
        
        guard let url = bundle?.url(forResource: "IMGUR_Uploader", withExtension: "momd") else { fatalError("Error loading model from the bundle") }
        let url1 = url.appendingPathComponent("IMGUR_Uploader.mom")
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url1) else { fatalError("Couldn't initialize managed object model from set url") }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let storageURL = documentURL.appendingPathComponent("IMGUR-Uploader.sqlite")
            
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageURL, options: nil)
            } catch {
                fatalError("Error adding persistent store \(error)")
            }
        } else {
            fatalError("Error locating storage")
        }
    }
    
    public func newLink() -> Link {
        return NSEntityDescription.insertNewObject(forEntityName: "Link", into: context) as! Link
    }
    
    private func fetchData(predicate : NSPredicate) -> [Link] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Link")
        
        fetchRequest.predicate = predicate
        
        do {
            let fetchResult = try context.fetch(fetchRequest) as! [Link]
            return fetchResult
        } catch {
            fatalError("Error fetching data!")
        }
    }
    
    public func getAllLinks() -> [Link] {
        return fetchData(predicate: NSPredicate(value: true))
    }
    
    public func removeLink(article : Link) {
        context.delete(article)
    }
    
    public func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
    }
    
    
}
