//
//  ManagerViewModel.swift
//  Chrononauts
//
//  Created by FredyCamas on 7/26/24.
//

import Foundation
import Combine

class PanoramaViewModel: ObservableObject {
    @Published var panoramas: [Panorama] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        let json = """
        [
            {"id": "1", "name": "msla", "panoImages": [{"name": "msla2011", "year": "2011"}, {"name": "msla2015", "year": "2015"}, {"name": "msla2020", "year": "2020"}], "latitude": 34.0578832, "longitude": -117.195714},
            {"id": "2", "name": "esri", "panoImages": [{"name": "esri2007", "year": "2007"}, {"name": "esri2011", "year": "2011"}, {"name": "esri2016", "year": "2016"},{"name": "esri2022", "year": "2022"}], "latitude": 34.0568832, "longitude": -117.196714},
            
        ]
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        if let panorama = try? decoder.decode([Panorama].self, from: data) {
            self.panoramas = panorama
        }
    }
}
