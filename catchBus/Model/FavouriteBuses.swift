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
    
    private(set) var favourites = [FavBusInfo]()

    func addToFavourites(favBus: FavBusInfo)->Bool{
        let isFavourite = self.favourites.contains(where: { fav in return fav == favBus })
        if isFavourite{
            return false
        } else {
            self.favourites.append(favBus)
            return true
        }
    }
    
    func getFavBusInfo(no: Int, stop: Int){
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
