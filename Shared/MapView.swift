//
//  MapView.swift
//  Enroute
//
//  Created by Joshua Olson on 11/20/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit

struct MapView: UIViewRepresentable {
    let annotations: [MKAnnotation]
    @Binding var selection: MKAnnotation?

    func makeUIView(context: Context) -> MKMapView {
        let mkMapView = MKMapView()
        mkMapView.delegate = context.coordinator
        mkMapView.addAnnotations(annotations)
        return mkMapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let annotation = selection else {
            return
        }
        let town = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        uiView.setRegion(MKCoordinateRegion(center: annotation.coordinate, span: town),
                         animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var selection: MKAnnotation?

        init(selection: Binding<MKAnnotation?>) {
            _selection = selection
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "MapViewAnnotation")
                ?? MKPinAnnotationView(annotation: annotation,
                                       reuseIdentifier: "MapViewAnnotation")
            view.canShowCallout = true
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            selection = annotation
        }
    }
}
