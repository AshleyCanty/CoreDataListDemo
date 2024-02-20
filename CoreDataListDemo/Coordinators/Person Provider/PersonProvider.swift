//
//  PersonProvider.swift
//  CoreDataListDemo
//
//  Created by ashley canty on 2/20/24.
//

import Foundation
import CoreData

final class PersonProvider {
    
    static let shared = PersonProvider()
    
    private let mainContext = CoreDataStack.shared.mainManagedObjectContext
    
    private let childContext = CoreDataStack.shared.privateManagedObjectContext
    
    private init() {}
    
    func fetchPeople() throws -> [Person] {
       // fetch data from core data to display in table view
        var personArray = [Person]()
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            // TODO: Set filtering and sorting
            
            /* Uncomment to test out filtering & sorting
             
             let arg = "Canty" // wildcard for variable
            let pred = NSPredicate(format: "name CONTAINS %@", arg)
            request.predicate = pred

            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort] */
            
            try mainContext.performAndWait {
                personArray = try mainContext.fetch(request)
            }
        } catch { }

        return personArray
    }
    
    func createPerson(name: String?, gender: String?, age: Int = 0) throws {
        let newPerson = Person(context: childContext)
        newPerson.name = name
        newPerson.age = Int64(age)
        newPerson.gender = gender
        
        try CoreDataStack.shared.saveChanges()
    }
    
    func updatePerson(_ editedPerson: Person) async throws {
        try await CoreDataStack.shared.updateData(objects: [editedPerson])
    }
    
    func deletePerson(_ selectedPerson: Person, completion: @escaping (() -> ())) async throws {
        try await CoreDataStack.shared.deleteData(objects: [selectedPerson], completion: {
            completion()
        })
    }
}
