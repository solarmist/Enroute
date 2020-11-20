//
//  Airline+CoreDataProperties.swift
//  Enroute
//
//  Created by Joshua Olson on 11/19/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData

extension Airline {
    @nonobjc public class func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Airline> {
        let request: NSFetchRequest = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }

    static func withCode(_ code: String, in context: NSManagedObjectContext) -> Airline {
        let request = fetchRequest(NSPredicate(format: "code_ = %@", code))
        let results = (try? context.fetch(request)) ?? []
        if let airline = results.first {
            return airline
        }

        let airline = Airline(context: context)
        airline.code = code
        AirlineInfoRequest.fetch(code) { info in
            let airline = self.withCode(code, in: context)
            airline.name = info.name
            airline.shortName = info.shortname

            airline.objectWillChange.send()
            airline.flights.forEach { $0.objectWillChange.send() }
            try? context.save()
        }
        return airline
    }

}

extension Airline: Comparable {
    var code: String {
        get { code_! }  // This is an error condition. If it every crashes here then add handler code
        set { code_ = newValue }
    }
    var name: String {
        get { name_ ?? code }
        set { name_ = newValue }
    }
    var shortName: String {
        get { (shortName_ ?? "").isEmpty ? name: shortName_! }
        set { shortName_ = newValue }
    }
    var flights: Set<Flight> {
        get { (flights_ as? Set<Flight>) ?? [] }
        set { flights_ = newValue as NSSet }
    }
    var friendlyName: String { shortName.isEmpty ? name : shortName }

    // swiftlint:disable:next identifier_name
    public var id: String { code }

    public static func < (lhs: Airline, rhs: Airline) -> Bool {
        lhs.name < rhs.name
    }

}
