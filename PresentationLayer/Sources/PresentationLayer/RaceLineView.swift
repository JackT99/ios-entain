//
//  RaceLineView.swift
//  Entain test
//
//  Created by Tomas Prekevicius on 10/12/2024.
//

import SwiftUI
import DomainLayer

public struct RaceListRow: View {
    @EnvironmentObject var vm: RaceViewModel
    let race: RSummary
    
    private var expired: Bool {
        return (race.advertised_start.seconds - vm.currTime) < 0
    }
    
    @State private var displayDetails = false

    func calcCountdown() -> String {
        var diff = race.advertised_start.seconds - vm.currTime
        diff = abs(diff)
        
        let h = diff / 3600
        diff -= h * 3600
        let m = diff / 60
        diff -= m * 60
        let s = diff
     
        let dateString = (expired ? "-" : "") + (h>0 ? "\(h)h " : "") + (m>0 ? "\(m)m " : "") + (s>0 ? "\(s)s" : "0s")

        return dateString
    }

    public var body: some View {
            HStack {
                Image(race.category_id, bundle: .main)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(Color("MainColour", bundle: .main).mix(with: Color.black, by: 0.3))
                VStack(alignment: .leading) {
                    Text(race.meeting_name)
                        .fontWeight(.semibold)
                    HStack {
                        Text("R"+String(race.race_number))
                        Spacer()
                        Text(calcCountdown())
                            .foregroundStyle(expired ? Color.red : .primary)
                    }
                }
                
            }
            .contentShape(Rectangle())
            .cornerRadius(15)
            .onTapGesture {
                withAnimation(){
                    displayDetails.toggle()
                }
            }
            if displayDetails {
                ZStack {
                    Color(.white).opacity(0.4)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("**Weather:** \(race.race_form?.weather?.name ?? "N/A")")
                            Text("**Track length:** \(String(race.race_form?.distance ?? 0))\(race.race_form!.distance_type?.short_name ?? "N/A")")
                        }
                        .foregroundStyle(Color("MainColour"))
                        Spacer()
                        
                    }
                    
                }
                .fixedSize(horizontal: false, vertical: true)
            
            }
    }
}


