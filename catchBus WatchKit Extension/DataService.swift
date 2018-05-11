//
//  DataService.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 3/29/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class DataService{
    static let instance = DataService()
    
    /* function to get all buses infos around
     */
    func getBusInfos(stopCode: String, handler: @escaping (_ busInfo: [BusInfo]) -> ()){
        var buses = [BusInfo]()
        
        // 45.414535,-75.671526
        let url = "https://api.octranspo1.com/v1.2/GetNextTripsForStopAllRoutes?appID=3afb3f7d&apiKey=2d67ca3957ddb9fe2c495dfa61657b1f&stopNo="+stopCode+"&format=json"

        //making a request to OC transpo API to get bus informations
        Alamofire.request(url).responseJSON { response in
            
            if response.result.error == nil{
                
                var routeNo: String!
                var routeHeading: String!
                var time: String!
                var bInfo: BusInfo!
                
                let jsonResponse = JSON(response.result.value!)

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
                print(response.result.error.debugDescription)
            }
            //filter buses out of service
            buses = buses.filter({bus in
                return bus.time != "-"
            })
            
            //sort by ascending arrival time
            buses.sort(by: {(bus1, bus2) in
                return Int(bus1.time)! < Int(bus2.time)!
            })
            handler(buses)
        }// end of API call
    }
    
    
    /*get stop number from json file
     */
    func getStopNumber(withStopName: String, handler: @escaping (_ stopNumber: String) -> ()){
        
        let path = Bundle.main.path(forResource: "stops", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        
        Alamofire.request(url).validate().responseJSON { response in
            if response.result.error == nil{
                let jsonResult = JSON(response.result.value!)
                let data = jsonResult["stops"].arrayValue
                
                for stop in data {
                    // Do something you want
                    if stop["stop_name"].stringValue == withStopName{
                        handler(stop["stop_code"].stringValue)
                        break
                    }
                }
            }
        }// end of api call
    }// end of getStopNumber
    
    
    /* Function to get name of the stop near by
     */
    func getStopName(location: String, handler: @escaping (_ stopName: String) -> ()){
       
        //let location = "45.414535,-75.671526"
        let API_KEY = "AIzaSyBmG3KTRGPdOgzuBqw_CUYlNbgLyV81xsM"
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+location+"&radius=1000&type=bus_station&key="+API_KEY
        
        Alamofire.request(url).responseJSON { response in
            
            if response.result.error == nil{
                let jsonResponse = JSON(response.result.value!)
                
                //get closestbus stop
                let closest = jsonResponse["results"][0]["name"].stringValue
                handler(closest.uppercased())
                
            } else {
                print(response.result.error.debugDescription)
            }
            
        }//end of api call
    }//end of getStopName
    

    
}
