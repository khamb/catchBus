//
//  FavouriteBuses.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/6/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation

class FavouriteBuses{
    static let instance = FavouriteBuses()
    
    private(set) var favourites = [Int:BusInfo]()
    
    func addToFavourites(bus: BusInfo)->Bool{
        if self.favourites[self.favourites.count] == nil{
            self.favourites[self.favourites.count] = bus
            return true
        }
        return false
    }
}
