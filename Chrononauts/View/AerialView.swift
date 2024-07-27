//
//  AerialView.swift
//  ARTest
//
//  Created by Owen on 7/26/24.
//

import SwiftUI
import ArcGIS

struct AerialView: View {
    init()
    {
    }
    init(long:Double, lat: Double) async
    {
        self.long = long
        self.lat = lat
    }
    init(panorama: Panorama){
        self.lat = panorama.latitude
        self.long = panorama.longitude
    }
    @State var Layers: Array<Layer> = Array<Layer>()
    @State var long: Double?
    @State var lat: Double?
    @State static var itemIDs = [
                                 ["97c32b6e568c4f2986cc1d4bd00d3c09", "2010", "Title"],
                                 ["0580885df74341d5b91aa431c69950ca", "2023", "Raster"],
                                 ["c7b2cf4fa4cb4df39ebb1a9338ab7229", "2022", "MapService"],
                                 ["decaa58fb5bf45d588d904a49e7ac1f1", "2019", "MapService"],
                                 ["eb0d93ab6b3e4c45a479885c90ad5a04", "2011", "MapService"],
                                 ["97c32b6e568c4f2986cc1d4bd00d3c09", "2010", "MapService"],
                                 
    ]
    
    @State private var map: Map = {
        let map = Map()
        return map
    }()
    var body: some View {
        VStack{
            MapView(map: map).task {
                map.initialViewpoint = Viewpoint(center:Point(x: self.long ?? -117.19492634116482,
                                                              y: self.lat ?? 34.05714608430707,
                                                              spatialReference: .wgs84),
                                                 scale: 1000)
                let portal = Portal(url: URL(string: "https://sbcounty.maps.arcgis.com")!, connection:.anonymous)
                for item in AerialView.itemIDs{
                    let portal_item = PortalItem(
                        portal: portal,
                        id: PortalItem.ID(item[0])!
                    )
                    var layer: Layer
                    if item[2] == "Raster" {
                        layer = RasterLayer(item: portal_item)
                    }else if item[2] == "MapService"{
                        layer = ArcGISMapImageLayer(item: portal_item)
                    }else
                    {
                        layer = ArcGISTiledLayer(item: portal_item)
                        layer.isVisible = false
                    }
                    try? await layer.load()
                    self.Layers.append(layer)
                }
                map.addOperationalLayers(self.Layers)
                try? await map.load()
                map.operationalLayers[0].isVisible = true
            }
            ScrollView(.horizontal, showsIndicators: false)
            {
                HStack{
                    ForEach(AerialView.itemIDs.indices, id: \.self) { idx in
                        Button(action: {
                            showLayer(index: idx)
                        })
                        {
                            Text(AerialView.itemIDs[idx][1])
                        }
                    }
                }
            }
        }
    }
    private func showLayer(index: Int)
    {
        for i in 0..<map.operationalLayers.count {
            if i == index{
                map.operationalLayers[i].isVisible = true
            }else{
                map.operationalLayers[i].isVisible = false
            }
        }
    }
}

#Preview {
    AerialView()
}
