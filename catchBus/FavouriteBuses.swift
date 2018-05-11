//
//  FavouriteBuses.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/6/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FavouriteBuses{
    static let instance = FavouriteBuses()
    
    private(set) var favourites = [BusInfo]() //[Int: (BusInfo,Int)] bus.no, BusInfo, stopNumber
    
    func addToFavourites(bus: BusInfo)->Bool{
        if self.favourites.contains(where: { favBus in return bus.no == favBus.no}){
            return false
        }
        self.favourites.append(bus)
        return true
    }
    
    func getBusInfo(no: Int, stop: Int){
        let url = "https://api.octranspo1.com/v1.2/GetNextTripsForStop?appID=3afb3f7d&apiKey=2d67ca3957ddb9fe2c495dfa61657b1f&routeNo=\(no)&stopNo=\(stop)"
        Alamofire.request(url).responseJSON(completionHandler: { response in
            
            if response.result.error == nil{
                let jsonResponse = JSON(response.result)
                print(jsonResponse)
            } else {
                print(response.result.error.debugDescription)
            }
        })
        
    }
}
