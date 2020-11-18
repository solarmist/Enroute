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
    var body: some Scene {
        WindowGroup {
            FlightsEnrouteView(
                flightSearch: FlightSearch(destination: "KGEG"))
        }
    }
}
