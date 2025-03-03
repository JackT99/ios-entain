//
//  Race.swift
//  Entain test
//
//  Created by Tomas Prekevicius on 10/12/2024.
//

import SwiftUI
import DomainLayer


public struct RefreshableView: View {
    @EnvironmentObject var vm: RaceViewModel

    struct Splash: View {
        @EnvironmentObject var vm: RaceViewModel
     
        var body: some View {
            if vm.isLoading {
                ZStack {
                    Color("bColour")
                        .ignoresSafeArea()
                    VStack {
                        Text("Next To Go Races loading...")
                            .font(.title2)
                        ProgressView()
                    }
               }
            }
        }
    }
    
    public var body: some View {
        List {
            
            ForEach(vm.raceData.filter( { let categ = $0.category_id ; return vm.categories.contains(where: { cat in cat.id == categ && cat.selected })
                                        }), id: \.race_id)  { race in
                                            RaceListRow(race: race)
                                                .listRowBackground(Color("bColour", bundle: .main))
                
            }
        }
        .background(Color("bColour", bundle: .main))
        .scrollContentBackground(.hidden)
        
        .overlay{Splash()}
        
        .refreshable {
            Task {
                await vm.fetchData()
            }
        }
      
        .onAppear {
            if vm.raceData.isEmpty || vm.raceData.count != vm.nbRaces {
                Task {
                    await vm.fetchData()
                    
                }
            }
        }
    }
}

public struct CategoryFilter: View {
    @EnvironmentObject private var vm: RaceViewModel
    
    public var body: some View {
        HStack() {
            Spacer()
            ForEach(0..<vm.categories.count, id: \.self) { i in
                
                Button(){
                    withAnimation {
                        $vm.categories[i].wrappedValue.toggleFilterSelected()  //wrappedValue.selected.toggle()
                    }
                } label: {Image(vm.categories[i].id).resizable().frame(width: 32, height: 32)}
                    .padding(.horizontal, 4)
                    .padding(4)
                    .background(vm.categories[i].selected ? Color("MainColour", bundle: .main) : .white)
                    .foregroundColor(vm.categories[i].selected ? .white : Color("MainColour", bundle: .main))
                    .bold()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("MainColour", bundle: .main), lineWidth: 1)
                    )
                    .cornerRadius(10)
                
                if i < vm.categories.count-1 {
                    Divider()
                }
            }
            Spacer()
            NavigationLink(destination: SettingsView(), label: {
                    Image(systemName: "line.3.horizontal").resizable().frame(width: 32, height: 32).foregroundStyle(.black)
                })
                    .padding(.trailing, 24)
        }
        .frame(height: 56)
        .background(Color("bColour", bundle: .main))
    }
}




public struct RaceView: View {
    public init() {}
    public var body: some View {
        NavigationView {
            VStack {
                CategoryFilter()
                    .frame(height: 40)
                RefreshableView()
            }
        }
        .statusBarHidden(false)
    }
        
}
    

#Preview {
    RaceView().environmentObject(RaceViewModel())
}
