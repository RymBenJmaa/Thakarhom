//
//  Connectivity.swift
//  Alzheimer
//
//  Created by ESPRIT on 12/01/2018.
//  Copyright © 2018 Esprit. All rights reserved.
//

import Foundation
import Alamofire
class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
