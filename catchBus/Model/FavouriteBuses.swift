//
//  FavouriteBuses.swift
//  catchBus
//
//  Created by Khadim Mbaye on 6/6/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import SwiftyJSON

class FavouriteBuses{
    static let instance = FavouriteBuses()
    
    private(set) var favourites = [FavBusInfo]()
    private(set) var favouriteStops = [String]()

    func addToFavourites(favBus: FavBusInfo)->Bool{
        let isFavourite = self.favourites.contains(where: { fav in return fav == favBus })
        if isFavourite{
            return false
        } else {
            self.favourites.append(favBus)
            return true
        }
    }
    
    func removeFromFavourites(favBus: FavBusInfo)->Bool{
        
        for i in 0..<self.favourites.count{
            if self.favourites[i] == favBus{
                self.favourites.remove(at: i)
                return true
            }
        }
        
        return false
    }
    
    func getFavBusInfo(no: Int, stop: Int){
        /*let url = "https://api.octranspo1.com/v1.2/GetNextTripsForStop?appID=3afb3f7d&apiKey=2d67ca3957ddb9fe2c495dfa61657b1f&routeNo=\(no)&stopNo=\(stop)"
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if error == nil{
                let jsonResponse = JSON(data!)
                print(jsonResponse)
            } else {
                print(error.debugDescription)
            }
        }).resume()*/
        
    }
}
