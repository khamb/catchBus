//
//  DataService.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 3/29/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import SwiftyJSON


class DataService{
    static let instance = DataService()
    
    /* function to get all buses infos around
     */
    
    private(set) var closestStopsName = ""
    private(set) var closestStops = [Stop]()
    
    func getBusInfos(handler: @escaping (_ busInfo: [BusInfo], _ stop: Stop) -> ()){
        var buses = [BusInfo]()
        
        for stop in self.closestStops{
            
            let url = "https://api.octranspo1.com/v1.2/GetNextTripsForStopAllRoutes?appID=3afb3f7d&apiKey=2d67ca3957ddb9fe2c495dfa61657b1f&stopNo="+stop.stopNo+"&format=json"

            let session = URLSession.shared
            
            //making a request to OC transpo API to get bus informations
            let apiTask = session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
  
                if error == nil{
                    
                    var routeNo: String!
                    var routeHeading: String!
                    var time: String!
                    var bInfo: BusInfo!
                    
                    let jsonResponse = JSON(data!)
                    
                    let routes = jsonResponse["GetRouteSummaryForStopResult"]["Routes"]["Route"].arrayValue
                    
                    for route in routes{
                        routeNo = route["RouteNo"].stringValue
                        routeHeading = route["RouteHeading"].stringValue
                        
                        for trip in route["Trips"].arrayValue{
                            time = trip["AdjustedScheduleTime"].stringValue
                            break
                        }
                        bInfo = BusInfo(no: routeNo, routeHeading: routeHeading, time: time ?? "-")
                        buses.append(bInfo)
                    }
                    
                } else {
                    print(error.debugDescription)
                }

                //filter buses out of service
                buses = buses.filter({bus in
                    return bus.time != "-"
                })
                
                //sort by ascending arrival time
                buses.sort(by: {(bus1, bus2) in
                    return Int(bus1.time)! < Int(bus2.time)!
                })

                handler(buses,stop)
            })
            apiTask.resume() // end of API call
        }
        
        
    }
    
    func makeApiCall(){
        
    }
    
    /*get stop number from json file
     */
    func getStopNumber(handler: @escaping (_ completed: Bool) -> ()){
        
        if !ViewController.allStops.isEmpty{
            for stop in ViewController.allStops{
                if stop.stopName == self.closestStopsName{
                    self.closestStops.append(stop)
                }
            }
            handler(true)
        } else{
            print("error getting stop number: all stops array is empty !")
            handler(false)
        }

    }// end of getStopNumber
    
    
    /* Function to get name of the stops near by a radius of 200
     */
    func getStopName(location: String, handler: @escaping (_ finished: Bool) -> ()){
        
        //let location = "45.414535,-75.671526"
        let API_KEY = "AIzaSyBmG3KTRGPdOgzuBqw_CUYlNbgLyV81xsM"
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+location+"&radius=200&type=bus_station&key="+API_KEY
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            
            if error == nil{
                let jsonResponse = JSON(data!)
                //get closestbus stops
                self.closestStopsName = jsonResponse["results"][0]["name"].stringValue.uppercased()
                handler(true)
                
            } else {
                print(error.debugDescription)
                handler(false)
            }
            
        }).resume()//end of api call
    }//end of getStopName
    
    func reset(){
        self.closestStops = []
        self.closestStopsName = ""
    }
    
    
    
}
