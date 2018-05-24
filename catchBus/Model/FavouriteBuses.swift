//
//  FavouriteBuses.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/6/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import SwiftyJSON

class FavouriteBuses{
    static let instance = FavouriteBuses()
    
    private(set) var favourites = [(String,BusInfo)]() //[Int: (BusInfo,Int)] bus.no, BusInfo, stopNumber

    func addToFavourites(bus: BusInfo, stopCode: String)->Bool{
        if self.favourites.contains(where: {(key,val) in return val.no==bus.no}) {
            return false
        }
        self.favourites.append((stopCode,bus))
        return true
    }
    
    func getBusInfo(no: Int, stop: Int){
        let url = "https://api.octranspo1.com/v1.2/GetNextTripsForStop?appID=3afb3f7d&apiKey=2d67ca3957ddb9fe2c495dfa61657b1f&routeNo=\(no)&stopNo=\(stop)"
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if error == nil{
                let jsonResponse = JSON(data!)
                print(jsonResponse)
            } else {
                print(error.debugDescription)
            }
        }).resume()
        
    }
}
