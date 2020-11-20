//
//  FilterFlights.swift
//  Enroute
//
//  Created by CS193p Instructor on 5/12/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import MapKit

struct FilterFlights: View {
    @FetchRequest(fetchRequest:Airport.fetchRequest(NSPredicate.all)) var airports: FetchedResults<Airport>
    @FetchRequest(fetchRequest:Airline.fetchRequest(NSPredicate.all)) var airlines: FetchedResults<Airline>

    @Binding var flightSearch: FlightSearch
    @Binding var isPresented: Bool

    @State private var draft: FlightSearch

    init(flightSearch: Binding<FlightSearch>, isPresented: Binding<Bool>) {
        _flightSearch = flightSearch
        _isPresented = isPresented
        _draft = State(wrappedValue: flightSearch.wrappedValue)
    }

    var destination: Binding<MKAnnotation?> {
        Binding<MKAnnotation?>(get: { draft.destination },
                              set: { annotation in
                                guard let airport = annotation as? Airport else { return }
                                draft.destination = airport
                              })
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Destination", selection: $draft.destination) {
                        ForEach(airports.sorted()) { airport in
                            Text("\(airport.friendlyName)").tag(airport)
                        }
                    }
                    // Change the style
                    //.pickerStyle(WheelPickerStyle())
                    MapView(annotations: airports.sorted(), selection: destination)
                        .frame(minHeight: 400)
                }
                Section {
                    Picker("Origin", selection: $draft.origin) {
                        Text("Any").tag(Airport?.none)
                        // Make the object an optional so the picker will work
                        ForEach(airports.sorted()) { (airport: Airport?) in
                            Text("\(airport?.friendlyName ?? "Any")").tag(airport)
                        }
                    }
                    Picker("Airline", selection: $draft.airline) {
                        Text("Any").tag(Airline?.none)
                        ForEach(airlines.sorted()) { (airline: Airline?) in
                            Text("\(airline?.friendlyName ?? "Any")").tag(airline)
                        }
                    }
                    Toggle(isOn: $draft.inTheAir) { Text("Enroute Only") }
                }
            }
            .navigationBarTitle("Filter Flights")
                .navigationBarItems(leading: cancel, trailing: done)
        }
    }

    var cancel: some View {
        Button(action: { isPresented = false},
               label: { Text("Cancel") }
        )
    }
    var done: some View {
        Button(action: {
            if draft.destination != flightSearch.destination {
                draft.destination.fetchIncomingFlights()
            }
            flightSearch = draft
            isPresented = false
        },
        label: { Text("Done") }
        )
    }
}

//struct FilterFlights_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterFlights()
//    }
//}
