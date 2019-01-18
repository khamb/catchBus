//
//  Route.swift
//  catchBus
//
//  Created by Khadim Mbaye on 1/17/19.
//  Copyright © 2019 Khadim Mbaye. All rights reserved.
//

import Foundation

struct APIResponseObject: Decodable{
    var stopSummary: StopSummary
    
    enum CodingKeys: String, CodingKey {
        case stopSummary = "GetRouteSummaryForStopResult"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stopSummary = try container.decode(StopSummary.self, forKey: .stopSummary)
    }
}


struct StopSummary: Decodable {
    var stopDescription: String
    var routes: [Route]

    enum CodingKeys: String, CodingKey {
        case stopDescription = "StopDescription"
        case routes = "Routes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stopDescription = try container.decode(String.self, forKey: .stopDescription)
        routes = try container.decode([String: [Route]].self, forKey: .routes)["Route"] ?? []
    }

}

struct Route: Decodable {
    var heading: String
    var no: Int
    var trips: [Trip]?

    enum CodingKeys: String, CodingKey {
        case heading = "RouteHeading"
        case no = "RouteNo"
        case trips = "Trips"
        
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        heading = try container.decode(String.self, forKey: .heading)
        no = try container.decode(Int.self, forKey: .no)
        
        do {
            trips = try container.decodeIfPresent([Trip].self, forKey: .trips)
        } catch let decodingError {
            if decodingError.localizedDescription == "Expected to decode Array<Any> but found a dictionary instead." {
                guard let singleTrip = try container.decodeIfPresent(Trip.self, forKey: .trips) else { throw decodingError }
                trips = [singleTrip]
            }
        } 
    }
}
