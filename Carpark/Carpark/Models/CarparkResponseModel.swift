//
//  CarparkResponseModel.swift
//  Carpark
//
//  Created by Yu Han on 15/08/2023.
//

import Foundation

struct CarparkResponse: Codable {
    let items: [CarparkData]
}

struct CarparkData: Codable {
    let timestamp: Date
    let carparkData: [CarparkInfo]
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case carparkData = "carpark_data"
    }
}

struct CarparkInfo: Codable {
    let carparkInfo: [Carpark]
    let carparkNumber: String
    let updateDatetime: String
    
    enum CodingKeys: String, CodingKey {
        case carparkInfo = "carpark_info"
        case carparkNumber = "carpark_number"
        case updateDatetime = "update_datetime"
    }
}

struct Carpark: Codable {
    let totalLots: String
    let lotType: String
    let lotsAvailable: String
    
    enum CodingKeys: String, CodingKey {
        case totalLots = "total_lots"
        case lotType = "lot_type"
        case lotsAvailable = "lots_available"
    }
}
