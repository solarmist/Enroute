//
//  EnrouteApp.swift
//  Enroute
//
//  Created by Joshua Olson on 11/18/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

@main
struct EnrouteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        let airport = Airport.withICAO("KSFO", in: persistenceController.container.viewContext)
        airport.fetchIncomingFlights()

        return WindowGroup {
            FlightsEnrouteView(
                flightSearch: FlightSearch(
                    destination: airport
                )
            )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
