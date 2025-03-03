//
//  Entain_testApp.swift
//  Entain test
//
//  Created by Tomas Prekevicius on 10/12/2024.
//

import SwiftUI
import DomainLayer
import PresentationLayer

@main
struct Entain_testApp: App {
    @StateObject var vm = RaceViewModel()
    var body: some Scene {
        WindowGroup {
            RaceView()
                .environmentObject(vm)
        }
    }
}
