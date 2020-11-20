//
//  Airport+CoreDataProperties.swift
//  Enroute
//
//  Created by Joshua Olson on 11/19/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//
//

import CoreData
import Combine
import MapKit

// Generated code from XCode for the model
// https://blckbirds.com/post/core-data-and-swiftui/

extension Airport: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    public var title: String? { name ?? icao }
    public var subtitle: String? { location }
}

extension Airport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Airport> {
        NSFetchRequest<Airport>(entityName: "Airport")
    }

    @nonobjc public class func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Airport> {
        let request: NSFetchRequest = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "location", ascending: true)]
        request.predicate = predicate
        return request
    }

    // swiftlint:disable:next identifier_name
    @NSManaged public var icao_: String?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var timezone: String?
    // swiftlint:disable:next identifier_name
    @NSManaged public var flightsFrom_: NSSet?
    // swiftlint:disable:next identifier_name
    @NSManaged public var flightsTo_: NSSet?

}

// MARK: Generated accessors for flightsFrom
extension Airport {

    @objc(addFlightsFromObject:)
    @NSManaged public func addToFlightsFrom(_ value: Flight)

    @objc(removeFlightsFromObject:)
    @NSManaged public func removeFromFlightsFrom(_ value: Flight)

    @objc(addFlightsFrom:)
    @NSManaged public func addToFlightsFrom(_ values: NSSet)

    @objc(removeFlightsFrom:)
    @NSManaged public func removeFromFlightsFrom(_ values: NSSet)

}

// MARK: Generated accessors for flightsTo
extension Airport {

    @objc(addFlightsToObject:)
    @NSManaged public func addToFlightsTo(_ value: Flight)

    @objc(removeFlightsToObject:)
    @NSManaged public func removeFromFlightsTo(_ value: Flight)

    @objc(addFlightsTo:)
    @NSManaged public func addToFlightsTo(_ values: NSSet)

    @objc(removeFlightsTo:)
    @NSManaged public func removeFromFlightsTo(_ values: NSSet)

}

extension Airport: Comparable, Identifiable {
    var icao: String {
        get { icao_! }  // This is an error condition. If it every crashes here then add handler code
        set { icao_ = newValue }
    }

    var flightsTo: Set<Flight> {
        get { flightsTo_ as? Set<Flight> ?? [] }
        set { flightsTo_ = newValue as NSSet }
    }

    var flightsFrom: Set<Flight> {
        get { flightsFrom_ as? Set<Flight> ?? [] }
        set { flightsFrom_ = newValue as NSSet }
    }

    var friendlyName: String {
        let friendly = AirportInfo.friendlyName(name: name ?? "", location: location ?? "")
        return friendly.isEmpty ? icao : friendly
    }

    // swiftlint:disable:next identifier_name
    public var id: String { icao }

    static func withICAO(_ icao: String, in context: NSManagedObjectContext) -> Airport {
        let request: NSFetchRequest = fetchRequest(NSPredicate(format: "icao_ = %@", icao))

        let results = (try? context.fetch(request)) ?? []
        if let airport = results.first {
            return airport
        }
        let airport = Airport(context: context)
        airport.icao = icao
        AirportInfoRequest.fetch(icao) { airportInfo in
            self.update(from: airportInfo, in: context)
        }

        return airport
    }

    static func update(from info: AirportInfo, in context: NSManagedObjectContext) {
        guard let icao = info.icao else {
            // failed
            print("Failed to update airport")
            return
        }
        print("Updating airport: \(icao)")

        let airport = Self.withICAO(icao, in: context)
        airport.latitude = info.latitude
        airport.location = info.location
        airport.longitude = info.longitude
        airport.name = info.name
        airport.timezone = info.timezone

        airport.objectWillChange.send()
        airport.flightsTo.forEach { $0.objectWillChange.send() }
        airport.flightsFrom.forEach { $0.objectWillChange.send() }
        try? context.save()
    }

    public static func < (lhs: Airport, rhs: Airport) -> Bool {
        (lhs.location ?? lhs.friendlyName) < (rhs.location ?? rhs.friendlyName)
    }

}

extension Airport {
    func fetchIncomingFlights() {
        Self.flightAwareRequest?.stopFetching()
        guard let context = managedObjectContext else {
            return
        }
        Self.flightAwareRequest = EnrouteRequest.create(airport: icao, howMany: 120)
        Self.flightAwareRequest?.fetch(andRepeatEvery: 30)
        Self.flightAwareResultsCancellable = Self.flightAwareRequest?.results.sink { results in
            print("Fetched \(results.count) flights")
            for faflight in results {
                Flight.update(from: faflight, in: context)
            }
            do {
                try context.save()
            } catch let error {
                print("Couldn't save flight update to CoreData: \(error.localizedDescription)")
            }
        }
    }

    private static var flightAwareRequest: EnrouteRequest!
    private static var flightAwareResultsCancellable: AnyCancellable?
}
