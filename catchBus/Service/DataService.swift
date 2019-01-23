//
//  DataService.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 5/29/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class DataService {
    static let instance = DataService()
    
//    Error    Note
//    1    Invalid API key
//    2    Unable to query data source
//    10    Invalid stop number
//    11      Invalid route number
//    12      Stop does not service route
    
    // MARK: - Private
    
    private(set) var stops: [Stop] = {
        var stops = [Stop]()
        
        guard let path = Bundle.main.url(forResource: "stops", withExtension: "json"),
            let data = try? Data(contentsOf: path) else { return stops }
        
        do {
             stops = try JSONDecoder().decode([Stop].self, from: data)
        } catch let decodingError{
            print("Error decoding stops array => \(decodingError)")
        }
        return stops
    }()
    
    private(set) var closestStopName: String = "" {
        didSet {
            self.closestStops = stops.filter({ stop in
                return stop.name == closestStopName.uppercased()
            })
        }
    }
    
    private(set) var closestStops: [Stop] = []
    
    // MARK: - Public
    
    func getRoutes(at stops: [Stop], handler: @escaping (_ routes: [Route]) -> ()){
        
        guard let stopCode = stops[0].code?.description else { return }
        let urlString = "https://api.octranspo1.com/v1.2/GetNextTripsForStopAllRoutes?appID=e1ba2999&apiKey=fe581e66b42592e76c5bf1fd5d9ea646&stopNo=\(stopCode)&format=json"

        let apiTask = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let decodedObject = try JSONDecoder().decode(APIResponseObject.self, from: data)
                handler(decodedObject.stopSummary.routes)
            } catch let decodingError {
                print(decodingError)
            }
        })
        apiTask.resume()
    }
    
    func getClosestStopName(at location: String, handler: @escaping (_ finished: Bool) -> ()){
        
        let API_KEY = "AIzaSyBmG3KTRGPdOgzuBqw_CUYlNbgLyV81xsM"
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+location+"&radius=500&type=bus_station&key="+API_KEY
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            
            guard error == nil, let data = data else { return }
            
            do {
                let results = try JSONDecoder().decode(ClosestStopAPIResponse.self, from: data).results
                guard let closestStopName = results.first?.name else { return }
                self.closestStopName = closestStopName
                handler(true)
            } catch let decodingError {
                print(decodingError)
                handler(false)
            }
        }).resume()
    }
}
