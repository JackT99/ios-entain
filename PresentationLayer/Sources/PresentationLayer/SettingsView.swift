//
//  SettingsView.swift
//  Entain test
//
//  Created by Tomas Prekevicius on 05/02/2025.
//

import SwiftUI
import DomainLayer

struct SettingsView: View {
    @EnvironmentObject private var settings: RaceViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Settings")
                    .font(.title2)
                Section(header: Text("Race settings")) {
                    Picker(selection: $settings.nbRaces, label: Text("Number of races to load")) {
                        ForEach(1..<21) { nb in
                            Text("\(nb)").tag(nb)
                        }
                    }
                    Picker(selection: $settings.retainRacesForSeconds, label: Text("Number of seconds before a race is removed from the list once started")) {
                        ForEach(1..<11) { sec in
                            Text("\(sec)").tag(sec)
                        }
                    }

                }
                Section(header: Text("Default category filters")) {
                    ForEach($settings.categories){cat in
                        Toggle(isOn: cat.selected) {
                            Text(cat.wrappedValue.name)
                        }
                    }
                }
            }
//            .background(Color("bColour"))
            .scrollContentBackground(.hidden)
        }
        .background(Color("bColour"))
    }
}

#Preview {
    SettingsView().environmentObject(RaceViewModel())
}

