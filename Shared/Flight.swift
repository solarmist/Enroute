//
//  Flight.swift
//  Enroute
//
//  Created by Joshua Olson on 11/19/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData

extension Flight {
    @nonobjc public class func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Flight> {
        let request: NSFetchRequest = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "arrival_", ascending: true)]
        request.predicate = predicate
        return request
    }

    @discardableResult
    static func update(from faflight: FAFlight, in context: NSManagedObjectContext) -> Flight {
        let request = fetchRequest(NSPredicate(format: "ident_ = %@", faflight.ident))
        let results = (try? context.fetch(request)) ?? []
        let flight = results.first ?? Flight(context: context)

        flight.ident = faflight.ident
        flight.arrival = faflight.arrival
        flight.departure = faflight.departure
        flight.filed = faflight.filed
        flight.aircraft = faflight.aircraft

        flight.origin = Airport.withICAO(faflight.origin, in: context)
        flight.destination = Airport.withICAO(faflight.destination, in: context)
        flight.airline = Airline.withCode(faflight.airlineCode, in: context)

        flight.objectWillChange.send()

        return flight
    }
}

// Protect these properties from being nil
extension Flight {
    var arrival: Date {
        get { arrival_ ?? Date(timeIntervalSinceReferenceDate: 0) }
        set { arrival_ = newValue }
    }

    var ident: String {
        get { ident_ ?? "Unknown" }
        set { ident_ = newValue }
    }

    var destination: Airport {
        get { destination_! }  // This is an error condition. If it every crashes here then add handler code
        set { destination_ = newValue }
    }

    var origin: Airport {
        get { origin_! }  // This is an error condition. If it every crashes here then add handler code
        set { origin_ = newValue }
    }

    var airline: Airline {
        get { airline_! }  // This is an error condition. If it every crashes here then add handler code
        set { airline_ = newValue }
    }

    var number: Int {
        Int(String(ident.drop(while: { !$0.isNumber }))) ?? 0
    }
}
