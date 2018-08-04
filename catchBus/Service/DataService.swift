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

class DataService{
    static let instance = DataService()
    
    /* function to get all buses infos around
     */
    private(set) var closestStopCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    private(set) var closestStopsName = ""
    private(set) var closestStops = [Stop]()
    
    
    func getBusInfoAtStop(stops: [Stop], handler: @escaping (_ busInfo: [BusInfo]) -> ()){
        var buses = [BusInfo]()
        
        for stop in stops{
            let url = "https://api.octranspo1.com/v1.2/GetNextTripsForStopAllRoutes?appID=3afb3f7d&apiKey=2d67ca3957ddb9fe2c495dfa61657b1f&stopNo="+stop.stopNo+"&format=json"
            
            let session = URLSession.shared
            
            //making a request to OC transpo API to get bus informations
            let apiTask = session.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
                
                if error == nil{
                    
                    var routeNo: String!
                    var routeHeading: String!
                    var time: String!
                    var bInfo: BusInfo!
                    
                    guard let data = data else {return}
                    
                    let jsonResponse = try! JSON(data: data)
                
                    let routes = jsonResponse["GetRouteSummaryForStopResult"]["Routes"]["Route"].arrayValue
                    
                    if routes.isEmpty{ //single route stops
                        let tmp = jsonResponse["GetRouteSummaryForStopResult"]["Routes"]["Route"].dictionaryValue
                        
                        if tmp["Trips"]?.dictionaryValue != nil{
                            routeNo = tmp["RouteNo"]?.stringValue
                            routeHeading = tmp["RouteHeading"]?.stringValue
                            time = tmp["Trips"]!["Trip"][0]["AdjustedScheduleTime"].stringValue
                            bInfo = BusInfo(no: routeNo, routeHeading: routeHeading, time: time)
                            buses.append(bInfo)
                        }
                        
                    } else { //multi routes stops
                        for route in routes{
                            
                            if !route["Trips"].arrayValue.isEmpty{// if there is no bus trips for that route got to next
                                routeNo = route["RouteNo"].stringValue
                                routeHeading = route["RouteHeading"].stringValue
                                time = route["Trips"][0]["AdjustedScheduleTime"].stringValue
                                bInfo = BusInfo(no: routeNo, routeHeading: routeHeading, time: time)
                                buses.append(bInfo)
                            }
                            
                        }
                    }
                    
                    //sort by ascending arrival time
                    buses.sort(by: {(bus1, bus2) in
                        if bus1.time == "-" || bus2.time == "-"{
                            return false
                        }
                        return Int(bus1.time)! < Int(bus2.time)!
                    })
                    
                    handler(buses)
                } else {
                    print(error.debugDescription)
                }
                
            })
            apiTask.resume() // end of API call
        }
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
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+location+"&radius=500&type=bus_station&key="+API_KEY
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            
            if error == nil{
                let jsonResponse = JSON(data!)
                //get closestbus stop
                self.closestStopsName = jsonResponse["results"][0]["name"].stringValue.uppercased()
                
                //get closest stop gps coordinate
                let lat = jsonResponse["results"][0]["geometry"]["location"]["lat"].doubleValue
                let long = jsonResponse["results"][0]["geometry"]["location"]["lng"].doubleValue
                self.closestStopCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                handler(true)
                
            } else {
                print(error.debugDescription)
                handler(false)
            }
            
        }).resume()//end of api call
    }//end of getStopName
    
    func reset(){
        self.closestStopCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.closestStops = []
        self.closestStopsName = ""
    }
    
    
    
}
