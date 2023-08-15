//
//  CarparkController.swift
//  Carpark
//
//  Created by Yu Han on 15/08/2023.
//

import Foundation

class CarparkController: ObservableObject {
    @Published var carparkCategoryData: [CarparkCategory] = []
    var carparkSmall: CarparkCategory = CarparkCategory(category: "Small", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
    var carparkMedium: CarparkCategory = CarparkCategory(category: "Medium", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
    var carparkBig: CarparkCategory = CarparkCategory(category: "Big", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
    var carparkLarge: CarparkCategory = CarparkCategory(category: "Large", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
    
    func startRefreshing() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            print("start refresh")
            self.fetchCarparkAvailability { result in
                switch result {
                    case .success:
                        print("successfully refresh")
                        break
                    case .failure(let error):
                        print("Error while refresh: \(error)")
                        break
                }
            }
        }
    }
    
    func fetchCarparkAvailability(completion: @escaping (Result<Void, Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Singapore")
        let currentDate = Date()

        let formattedDate = dateFormatter.string(from: currentDate)
        
        let queryParams = [
            "date_time": formattedDate
        ]
        
        var components = URLComponents(string: "https://api.data.gov.sg/v1/transport/carpark-availability")!
        components.queryItems = queryParams.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(CarparkResponse.self, from: data)
                
                self.resetCategory()
                
                for carparkData in response.items {
                    for carparkInfo in carparkData.carparkData {
                        self.checkCarparkCategory(carparkInfo: carparkInfo)
                    }
                    
                    DispatchQueue.main.async {
                        self.carparkCategoryData = []
                        self.carparkCategoryData.append(self.carparkSmall)
                        self.carparkCategoryData.append(self.carparkMedium)
                        self.carparkCategoryData.append(self.carparkBig)
                        self.carparkCategoryData.append(self.carparkLarge)
                    }
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func resetCategory() {
        carparkSmall = CarparkCategory(category: "Small", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
        carparkMedium = CarparkCategory(category: "Medium", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
        carparkBig = CarparkCategory(category: "Big", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
        carparkLarge = CarparkCategory(category: "Large", highestSlotCount: 0, lowestSlotCount: 0, highestCarpark: [], lowestCarpark: [])
    }
    
    func checkCarparkCategory(carparkInfo: CarparkInfo) {
        var totalLots = 0
        var availableLots = 0
        
        for carpark in carparkInfo.carparkInfo {
            if let tempLots = Int(carpark.totalLots), let tempLotsAvailable = Int(carpark.lotsAvailable) {
                totalLots += tempLots
                availableLots += tempLotsAvailable
            }
        }
        
        if(totalLots < 100) {
            self.appendCarpark(carparkCategory: &carparkSmall, availableLots: availableLots, carparkInfo: carparkInfo)
        } else if (totalLots < 300) {
            self.appendCarpark(carparkCategory: &carparkMedium, availableLots: availableLots, carparkInfo: carparkInfo)
        } else if (totalLots < 400) {
            self.appendCarpark(carparkCategory: &carparkBig, availableLots: availableLots, carparkInfo: carparkInfo)
        } else {
            self.appendCarpark(carparkCategory: &carparkLarge, availableLots: availableLots, carparkInfo: carparkInfo)
        }
    }
    
    func appendCarpark(carparkCategory: inout CarparkCategory, availableLots: Int, carparkInfo: CarparkInfo) {
        if(carparkCategory.highestCarpark.isEmpty && carparkCategory.lowestCarpark.isEmpty) {
            carparkCategory.highestSlotCount = availableLots
            carparkCategory.lowestSlotCount = availableLots
            carparkCategory.highestCarpark.append(carparkInfo.carparkNumber)
            carparkCategory.lowestCarpark.append(carparkInfo.carparkNumber)
        } else if (carparkCategory.highestSlotCount < availableLots) {
            carparkCategory.highestSlotCount = availableLots
            carparkCategory.highestCarpark = []
            carparkCategory.highestCarpark.append(carparkInfo.carparkNumber)
        } else if (carparkCategory.lowestSlotCount > availableLots) {
            carparkCategory.lowestSlotCount = availableLots
            carparkCategory.lowestCarpark = []
            carparkCategory.lowestCarpark.append(carparkInfo.carparkNumber)
        } else if (carparkCategory.highestSlotCount == availableLots) {
            carparkCategory.highestCarpark.append(carparkInfo.carparkNumber)
        } else if (carparkCategory.lowestSlotCount == availableLots) {
            carparkCategory.lowestCarpark.append(carparkInfo.carparkNumber)
        }
    }
}
