//
//  CoreDataStack.swift
//  CoreDataListDemo
//
//  Created by ashley canty on 2/19/24.
//

import Foundation
import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    private let moduleName = "CoreDataListDemo"
    
    private lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: moduleName)
        
        container.loadPersistentStores { _, err in
            if let err {
                fatalError("Failed to load persistent stores: \(err.localizedDescription)")
            }
        }
        return container
    }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = mainManagedObjectContext
        return privateContext
    }()
    
    
    private init() {}
 
}

extension CoreDataStack {
    
    fileprivate func throwSaveError(_ error: CoreDataError?) throws {
        throw CoreDataError.unableToSave(objectDetails: "Unable to save changes: \(String(describing: error?.localizedDescription))")
    }
    
    func saveChanges() throws {
        do {
            try self.privateManagedObjectContext.save()
            try self.mainManagedObjectContext.performAndWait {
                do {
                    try self.mainManagedObjectContext.save()
                } catch (let error) {
                    try throwSaveError(error as? CoreDataError)
                }
            }
        } catch (let error) {
            try throwSaveError(error as? CoreDataError)
        }
    }
    
    func addNewData<T: NSManagedObject>(objects: [T]) throws {
        privateManagedObjectContext.perform {
            for object in objects {
                self.privateManagedObjectContext.insert(object)
            }
        }
        
        // Save changes to private context and merge changes to main context
        try saveChanges()
    }
    
    func updateData<T: NSManagedObject>(objects: [T]) async throws {
        try await privateManagedObjectContext.perform { [weak self] in
            guard let self = self else {
                let objectDetails = "Unable to update object(s): \(objects.description)"
                throw CoreDataError.unableToUpdate(objectDetails: objectDetails)
            }
            for object in objects {
                if object.managedObjectContext == self.privateManagedObjectContext {
                    object.managedObjectContext?.refresh(object, mergeChanges: true)
                } else {
                    let fetchRequest = NSFetchRequest<T>(entityName: object.entity.name!)
                    fetchRequest.predicate = NSPredicate(format: "SELF == %@", object)
                    fetchRequest.fetchLimit = 1
                    
                    if let fetchedObject = try? self.privateManagedObjectContext.fetch(fetchRequest).first {
                        fetchedObject.setValuesForKeys(object.dictionaryWithValues(forKeys: object.entity.attributesByName.enumerated().map { $0.element.key }))
                    }
                }
            }
            
            try saveChanges()
        }
    }
    
    func deleteData<T: NSManagedObject>(objects: [T], completion: @escaping (() -> ())) async throws {
        try await privateManagedObjectContext.perform { [weak self] in
            guard let self = self else {
                let objectDetails = "Unable to delete object(s): \(objects.description)"
                throw CoreDataError.unableToDelete(objectDetails: objectDetails)
            }
            for object in objects {
                if object.managedObjectContext == self.privateManagedObjectContext {
                    self.privateManagedObjectContext.delete(object)
                } else {
                    if let objectInContext = self.privateManagedObjectContext.object(with: object.objectID) as? T {
                        self.privateManagedObjectContext.delete(objectInContext)
                        print()
                    }
                }
            }
            try saveChanges()
            completion()
        }
    }
}
