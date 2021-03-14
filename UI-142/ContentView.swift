//
//  ContentView.swift
//  UI-142
//
//  Created by にゃんにゃん丸 on 2021/03/13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      Home()
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct Home : View {
    @StateObject var model = DateViewModel()
    var body: some View{
        
        ZStack{
            
            Text(model.selectedDate,style: .time)
                .font(.largeTitle)
                
               
                
            
                .bold()
                .onTapGesture {
                    model.setTime()
                    withAnimation(.spring()){
                        
                        model.showpicker.toggle()
                    }
                }
            
            if model.showpicker{
                
                VStack{
                    
                    
                    HStack(spacing:18){
                        
                        Spacer()
                        HStack(spacing:0){
                            
                            Text("\(model.hour):")
                                .font(.largeTitle)
                                .fontWeight(model.ChangeToMin ? .light : .bold)
                                .onTapGesture {
                                    model.angle = Double(model.hour * 30)
                                    model.ChangeToMin = false
                                }
                            
                            Text("\(model.minutes < 10 ? "0" : "")\(model.minutes)")
                                .font(.largeTitle)
                                .fontWeight(model.ChangeToMin ? .light : .bold)
                                .onTapGesture {
                                    model.angle = Double(model.minutes * 6)
                                    model.ChangeToMin = true
                                }
                               
                              
                            
                        }
                        .padding()
                        
                        VStack(spacing:6){
                            
                            Text("AM")
                                .font(.title2)
                                .fontWeight(model.symbol == "AM" ? .light : .bold)
                                .onTapGesture {
                                    model.symbol = "AM"
                                }
                            
                            Text("PM")
                                .font(.title2)
                                .fontWeight(model.symbol == "PM" ? .light : .bold)
                                .onTapGesture {
                                    model.symbol = "PM"
                                }
                                
                                
                            
                            
                        }
                        .frame(width: 50)
                    }
                    .padding()
                    .foregroundColor(.white)
                    
                    
                    
                    TimeSlider()
                    HStack{
                        
                        Spacer()
                        
                        Button(action:
                            model.generateTime
                            
                        , label: {
                            Text("SAVE")
                                .bold()
                        })
                    }
                    .padding()
                }
                .frame(width: getwidth() - 120)
                .background(Color.primary)
                .cornerRadius(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.primary.opacity(0.03))
                .onTapGesture {
                    withAnimation(.spring()){
                        
                        model.showpicker.toggle()
                        model.ChangeToMin = false
                    }
                }
                .environmentObject(model)
                
            }
            
            
            
        }
    
        
    }
}

class DateViewModel : ObservableObject{
    
    @Published var selectedDate = Date()
    @Published var showpicker = false
    
    @Published var hour : Int = 12
    @Published var minutes : Int = 0
    
    
    @Published var ChangeToMin = false
    @Published var symbol = "AM"
    
    @Published var angle : Double = 0
    
    func setTime(){
        
        let calender = Calendar.current
        hour = calender.component(.hour, from: selectedDate)
        symbol = hour  <= 12 ? "AM" : "PM"
        hour = hour == 0 ? 12 : hour
        hour  = hour <= hour ? hour : hour - 12
        minutes = calender.component(.minute, from: selectedDate)
       angle = Double(hour * 30)
        
        
        
    }
    
    func generateTime(){
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        let currentHourValue = symbol == "AM" ? hour : hour + 12
        let date = format.date(from: "\(currentHourValue):\(minutes)")
        self.selectedDate = date!
        withAnimation{
            
            showpicker.toggle()
            ChangeToMin = false
        }
        
        
    }
    
    
    
}

extension View{
    
    func getwidth()->CGFloat{
        
        return UIScreen.main.bounds.width
    }
}

struct TimeSlider: View {
    @EnvironmentObject var model : DateViewModel
    var body: some View {
        GeometryReader{reader in
            
            let width = reader.frame(in:.global).width / 2
            
            ZStack{
                

                Circle()
                    .fill(Color.red)
                    .frame(width: 40, height: 40)
                    .offset(x:width - 50)
                    .rotationEffect(.init(degrees: model.angle))
                
                    .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnded(value:)))
                    .rotationEffect(.init(degrees: -90))
                    
                    
                  


                ForEach(1...12,id:\.self){index in

                    VStack(spacing:0){
                        Text("\(model.ChangeToMin ? index * 5 : index)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .rotationEffect(.init(degrees: Double(-index) * 30))
                        
                    }
                    .offset(y: -width + 50)
                    .rotationEffect(.init(degrees: Double(index) * 30))
                }

                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            
                    .overlay(
                    
                    Rectangle()
                        
                        .fill(Color.blue)
                        .frame(width: 2, height: width / 1.8)
                        
                        
                        ,alignment: .bottom
                        
                        
                    )
                    .rotationEffect(.init(degrees: model.angle))
                
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment:.center)
            
        }
        .frame(height: 300)
        
    }
    
    func onChanged(value : DragGesture.Value){
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radius = atan2(vector.dy - 20, vector.dx - 20)
        var angle = radius * 180 / .pi
        
        if angle < 0{angle = 360 + angle}
        
        model.angle = Double(angle)
        
        if !model.ChangeToMin{
            
            
            let roundValue = 30 * Int(model.angle / 30)
            model.angle = Double(roundValue)
        }
        else{
            
            let progess = model.angle / 360
            model.minutes = Int(progess * 60)
        }
        
        
    }
    func onEnded(value : DragGesture.Value){
        
        if !model.ChangeToMin{
            
            model.hour = Int(model.angle / 30)
            
        }
        
        withAnimation{
            model.angle = Double(model.minutes * 6)
            
            model.ChangeToMin = true
        }
        
        
    }
}
