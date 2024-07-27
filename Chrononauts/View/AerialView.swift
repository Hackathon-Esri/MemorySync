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
    @State var Layers: Array<ArcGISMapImageLayer> = Array<ArcGISMapImageLayer>()
    @State var long: Double?
    @State var lat: Double?
    @State static var itemIDs = [
                                 ["0580885df74341d5b91aa431c69950ca", "2023", "Raster"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2022_pua_cache/MapServer", "2022", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2021_pua_cache/MapServer", "2021", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2020_pua_cache/MapServer", "2020", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2019_StatePlane/MapServer", "2019", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2018_pua_cache/MapServer", "2018", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2017_pua_cache/MapServer", "2017", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2016_pua_cache/MapServer", "2016", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2015_pua_cache/MapServer", "2015", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2014_pua_cache/MapServer", "2014", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2013_pua_cache/MapServer", "2013", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2012_pua_cache/MapServer", "2012", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2011_pua_cache/MapServer", "2011", "URL"],
                                 ["https://maps.sbcounty.gov/arcgis/rest/services/Y2010_pua_cache/MapServer", "2010", "URL"],
                                 
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
                    if item[2] == "Raster" {
                        let layer = RasterLayer(item: portal_item)
                        try? await layer.load()
                        layer.isVisible = false
                        map.addOperationalLayer(layer)
                    }else if item[2] == "MapService"{
                        let layer = ArcGISMapImageLayer(item: portal_item)
                        try? await layer.load()
                        layer.isVisible = false
                        map.addOperationalLayer(layer)
                    }else
                    {
                        let layer = ArcGISMapImageLayer(url: URL(string: item[0])!)
                        try? await layer.load()
                        layer.isVisible = false
                        map.addOperationalLayer(layer)
                    }
                }
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
