//
//  Stop.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import CoreLocation

struct ClosestStopAPIResponse: Decodable {
    var status: String?
    var results: [Stop]
}

struct Geometry: Decodable {
    var locations: [String: Double]
//    var latitude: Double
//    var longitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case locations = "location"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        locations = try container.decode([String: Double].self, forKey: .locations)
    }
}

struct Stop: Decodable{
    var geometry: Geometry?
    var code: Int?
    var name: String
}



