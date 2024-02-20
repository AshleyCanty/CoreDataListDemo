//
//  CoreDataErrors.swift
//  CoreDataListDemo
//
//  Created by ashley canty on 2/20/24.
//

import Foundation


enum CoreDataError: Swift.Error {
    case unableToSave(objectDetails: String)
    case unableToUpdate(objectDetails: String)
    case unableToReadData
    case unableToDelete(objectDetails: String)
}
