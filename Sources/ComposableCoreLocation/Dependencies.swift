//
//  Dependencies.swift
//  
//
//  Created by Roberto Casula on 18/10/22.
//

import Dependencies
import Foundation

extension DependencyValues {
    public var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}

extension LocationManager: DependencyKey {
    public static let testValue = Self.failing
    public static var liveValue = Self.live
}
