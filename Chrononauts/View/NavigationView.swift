//
//  InitialMapView.swift
//  ARTest
//
//  Created by Owen on 7/26/24.
//
// id: Item.ID(rawValue: "fae788aa91e54244b161b59725dcbb2a")!
import SwiftUI
import ArcGIS
import CoreLocation

struct MapNavigationView: View {
    @StateObject private var panoramaViewModel = PanoramaViewModel()
    @StateObject private var locationManager = LocationManagerShared()
    
    private static let portal_item = PortalItem(
        portal: .arcGISOnline(connection: .anonymous),
        id: Item.ID(rawValue: "fae788aa91e54244b161b59725dcbb2a")!
    )
    
    @State private var graphicsOverlay = GraphicsOverlay()
    @State private var map: Map?
    @State private var tapScreenPoint: CGPoint?
    @State private var isShowingIdentifyResultAlert = false
    @State private var identifyResultMessage = "" {
        didSet { isShowingIdentifyResultAlert = identifyResultMessage.isEmpty }
    }
    @State private var error: Error?
    
    @State private var selectedPanorama: Panorama?
    @State private var isNavigationActive: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let map = map {
                    MapViewReader { mapViewProxy in
                        MapView(map: map, graphicsOverlays: [graphicsOverlay])
                            .onSingleTapGesture { screenPoint, _ in
                                tapScreenPoint = screenPoint
                            }
                            .task(id: tapScreenPoint) {
                                guard let tapScreenPoint else { return }
                                await handleTap(screenPoint: tapScreenPoint, mapViewProxy: mapViewProxy)
                            }
                            .alert(
                                "Identify Result",
                                isPresented: $isShowingIdentifyResultAlert,
                                actions: {},
                                message: { Text(identifyResultMessage) }
                            )
                            .onAppear {
                                updateGraphicsOverlay()
                            }
                            .onChange(of: panoramaViewModel.panoramas) { _ in
                                updateGraphicsOverlay()
                            }
                            .overlay(
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            Task {
                                                await goToCurrentLocation(mapViewProxy: mapViewProxy)
                                            }
                                        }) {
                                            Image(systemName: "location.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.blue)
                                                .padding()
                                                .padding(.bottom)
                                            
                                        }
                                    }
                                }
                            )
                    }
                } else {
                    ProgressView("Loading map...")
                        .onAppear {
                            setupMap()
                        }
                }
            }
            .background(
                NavigationLink(
                    destination: selectedPanorama.map { panorama in
                        BridgeStreetView(panorama: panorama)
                    },
                    isActive: $isNavigationActive
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
    
    private func setupMap() {
        if let location = locationManager.lastLocation {
            let point = Point(
                x: location.coordinate.longitude,
                y: location.coordinate.latitude,
                spatialReference: .wgs84
            )
            map = Map(item: MapNavigationView.portal_item)
            map?.initialViewpoint = Viewpoint(center: point, scale: 4e4)
        } else {
            // Fallback to a default location if current location is not available
            let point = Point(
                x: -117.15,
                y: 34.1,
                spatialReference: .wgs84
            )
            map = Map(item: MapNavigationView.portal_item)
            map?.initialViewpoint = Viewpoint(center: point, scale: 4e4)
        }
    }
    
    @MainActor
    private func handleTap(screenPoint: CGPoint, mapViewProxy: MapViewProxy) async {
        do {
            let identifyResult = try await mapViewProxy.identify(
                on: graphicsOverlay,
                screenPoint: screenPoint,
                tolerance: 12
            )
            
            if identifyResult.graphics.isNotEmpty {
                let graphic = identifyResult.graphics.first
                let id = graphic?.attributes["id"] as! String
                identifyResultMessage = "Tapped on a panorama image, id: \(id), Jumping to Panorama View..."
                
                if let panorama = panoramaViewModel.panoramas.first(where: { $0.id == id }) {
                    selectedPanorama = panorama
                    isNavigationActive = true // Trigger the navigation
                }
            }
        } catch {
            self.error = error
        }
        
        self.tapScreenPoint = nil
    }
    
    @MainActor
    private func goToCurrentLocation(mapViewProxy: MapViewProxy) async {
        if let location = locationManager.lastLocation {
            do {
                let point = Point(
                    x: location.coordinate.longitude,
                    y: location.coordinate.latitude,
                    spatialReference: .wgs84
                )
                try await mapViewProxy.setViewpoint(Viewpoint(center: point, scale: 4e4))
            } catch {
                print("Error moving to current location: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateGraphicsOverlay() {
        let graphics = panoramaViewModel.panoramas.map { pano in
            makePictureMarkerSymbolFromImage(x: pano.longitude, y: pano.latitude, id: pano.id)
        }
        graphicsOverlay.addGraphics(graphics)
    }
    
    private func makePictureMarkerSymbolFromImage(x: Double, y: Double, id: String) -> Graphic {
        let imageName = "panorama_icon"
        let pinSymbol = PictureMarkerSymbol(image: resizeImage(image: UIImage(named: imageName)!, newWidth: 100))
        let pinPoint = Point(x: x, y: y, spatialReference: .wgs84)
        let attr = ["id": id]
        let pinGraphic = Graphic(geometry: pinPoint, attributes: attr, symbol: pinSymbol)
        return pinGraphic
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

private extension Collection {
    /// A Boolean value indicating whether the collection is not empty.
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

#Preview {
    MapNavigationView()
}
