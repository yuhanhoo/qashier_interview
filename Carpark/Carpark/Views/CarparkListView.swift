//
//  CarparkListView.swift
//  Carpark
//
//  Created by Yu Han on 15/08/2023.
//

import SwiftUI

struct CarparkListView: View {
    @State private var errorFlag: Bool = false
    @StateObject private var carparkController = CarparkController()
    
    func callCarparkWS() {
        errorFlag = false
        carparkController.fetchCarparkAvailability { result in
            switch result {
                case .success:
                    errorFlag = false
                    print(result)
                    break
                case .failure(let error):
                    errorFlag = true
                    print("Error fetching carpark availability: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if carparkController.carparkCategoryData.isEmpty && !self.errorFlag {
                    ProgressView("Fetching Carpark Data...")
                } else if (self.errorFlag) {
                    Button(action: {
                        callCarparkWS()
                    }) {
                        Text("Opsss, an error occurred!\nClick me to refresh")
                            .foregroundColor(.black)
                    }
                } else {
                    List(carparkController.carparkCategoryData.indices, id: \.self) { index in
                        CarparkRowView(carparkAvailable: carparkController.carparkCategoryData[index])
                    }
                }
            }
            .navigationBarTitle("Carpark Availability")
            .onAppear {
                carparkController.startRefreshing()
                callCarparkWS()
            }
        }
    }
}

struct CarparkRowView: View {
    var carparkAvailable: CarparkCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(carparkAvailable.category) Carpark\n").bold().font(.system(size: 24))
            Text("Highest Carpark (\(carparkAvailable.highestSlotCount) lots available)").bold()
            Text("\(carparkAvailable.highestCarpark.joined(separator: ", "))\n").font(.system(size: 15))
            Text("Lowest Carpark (\(carparkAvailable.lowestSlotCount) lots available)").bold()
            Text("\(carparkAvailable.lowestCarpark.joined(separator: ", "))\n").font(.system(size: 15))
        }.listRowInsets(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
    }
}

struct CarparkListView_Previews: PreviewProvider {
    static var previews: some View {
        CarparkListView()
    }
}
