//
//  ModelData.swift
//  Entain test
//
//  Created by Tomas Prekevicius on 10/12/2024.
//

import Foundation
import Combine
import SwiftUI
import DataLayer


public struct RSummary: Codable, Sendable {
    public let race_id: String?
    public let race_name: String?
    public let race_number: Int
    let meeting_id: String?
    public let meeting_name: String
    public let category_id: String
    public let advertised_start: ADVERTISED_START
    public struct ADVERTISED_START: Codable, Sendable {
        public let seconds: Int
    }
    public let race_form: RACE_FORM?
    public struct RACE_FORM: Codable, Sendable {
        public let distance: Int?
        public let distance_type: DISTANCE_TYPE?
        public struct DISTANCE_TYPE: Codable, Sendable {
            let id: String?
            let name: String?
            public let short_name: String?
        }
        let distance_type_id: String?
        let track_condition: TRACK_CONDITION?
        struct TRACK_CONDITION: Codable {
            let id: String?
            let name: String?
            let short_name: String?
        }
        let track_condition_id: String?
        public let weather: WEATHER?
        public struct WEATHER: Codable, Sendable {
            let id: String?
            public let name: String?
            let short_name: String?
            let icon_uri: String?
        }
        let weather_id: String?
        let race_comment: String?
        let additional_data: String?
        let generated: Int?
        let silk_base_url: String?
        let race_comment_alternative: String?
    }
    let venue_id: String?
    let venue_name: String?
    let venue_state: String?
    let venue_country: String?
}

struct Response: Codable, Sendable {
    let status: Int
    let data: DATA
    struct DATA: Codable, Sendable {
        let next_to_go_ids: [String]
        let race_summaries: [String:RSummary]
    }
    let message: String
 }


@MainActor
public class RaceViewModel: ObservableObject {
    
    public struct Category: Identifiable, Hashable {
        public let name: String
        public let id: String
        public var selected: Bool
        
        public mutating func toggleFilterSelected() {
            selected.toggle()
            @AppStorage("\(id)_filter") var storeVal: Bool = true
            storeVal = selected
        }
    }
    
    @Published public var raceData = [RSummary]()
    
    @Published public var isLoading = false
      
    @Published public var categories: [Category] = [
        Category(name: "Horses", id: "4a2788f8-e825-4d36-9894-efd4baf1cfae", selected: true),
        Category(name: "Greyhounds", id: "9daef0d7-bf3c-4f50-921d-8e818c60fe61", selected: true),
        Category(name: "Harness", id: "161d9be2-e909-4326-8c2c-35ed71fb460b", selected: true)
    ]
    
    @AppStorage("nbRaces") public var nbRaces: Int = 20
    @AppStorage("retainRacesForSeconds") public var retainRacesForSeconds: Int = 10
    
    @Published public var currTime: Int = Int(Date().timeIntervalSince1970)
    private var timer: AnyCancellable?
    
    public init() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.currTime = Int(Date().timeIntervalSince1970)
                // Expire events from the list, if any, and refresh the list
                let readyToExpire = self.raceData.filter { ((self.currTime - $0.advertised_start.seconds) > self.retainRacesForSeconds) }.count
                if (readyToExpire != 0 || self.raceData.count != self.nbRaces) && (self.currTime % 10 == 0) {
                    //print("Refreshing! ReadyToExpire: \(readyToExpire). Count is \(self.raceData.count) and number of races to fetch is \(self.nbRaces)")
                    Task(priority: .medium){
                        await self.fetchData()
                    }
                }
            }
    }
    
    @MainActor
    public func fetchData() async {
       // isLoading = true
        guard let resp: Response = await EntainAPI().getNextToGoRaces(limit: nbRaces) else { isLoading = false; return}
        // Fetch , sort and filter current list of events within our criteria
        var fetchedData = resp.data.race_summaries.values.sorted { $0.advertised_start.seconds < $1.advertised_start.seconds}.filter({(currTime < $0.advertised_start.seconds) || (abs($0.advertised_start.seconds - currTime) < retainRacesForSeconds)})
        // Remove all expired events from our data
        raceData.removeAll(where: { ((currTime - $0.advertised_start.seconds) > retainRacesForSeconds) })
        // Only leave fetched data that we do not have yet
        for race in raceData {
            fetchedData.removeAll(where: {$0.race_id == race.race_id})
        }
        // If there is anything new - append it to our data
        if !fetchedData.isEmpty {
                raceData.append(contentsOf: fetchedData)
        } else
            if raceData.count > nbRaces {
                raceData = fetchedData
            }
       // isLoading = false
    }
    


}
