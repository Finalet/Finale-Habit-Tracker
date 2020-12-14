//
//  Habit_Widget.swift
//  Habit Widget
//
//  Created by Grant Oganyan on 12.12.2020.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct Habit_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        GeometryReader { geo in
            Rectangle()
                .fill(Color("app.background"))
            Group {
                Rectangle()
                    .fill(Color("pastel.green.secondary"))
                    .frame(width: geo.size.width * 0.9, height: geo.size.height / 3.5, alignment: .center)
                    .cornerRadius(geo.size.height / 7)
                    .position(x: geo.size.width * 0.5, y: geo.size.height/5)
                Image("pan")
                    .resizable()
                    .position(x: geo.size.width * 0.05 + geo.size.height / 8 + 4, y: geo.size.height/5)
                    .frame(width: geo.size.height / 4, height: geo.size.height / 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .shadow(radius: 4)
                Text("Rotate Eyes")
                    .frame(width: geo.size.width * 0.55, height: geo.size.height / 10, alignment: .leading)
                    .position(x: geo.size.width * 0.63, y: geo.size.height/5)
                    .foregroundColor(.white)
                    .truncationMode(.tail)
                    .font(.system(size:15))
            }
            Group {
                Rectangle()
                    .fill(Color("bright.trueblue.secondary"))
                    .frame(width: geo.size.width * 0.9, height: geo.size.height / 3.5, alignment: .center)
                    .cornerRadius(geo.size.height / 7)
                    .position(x: geo.size.width * 0.5, y: geo.size.height/2)
                Image("pan")
                    .resizable()
                    .position(x: geo.size.width * 0.05 + geo.size.height / 8 + 4, y: geo.size.height/2)
                    .frame(width: geo.size.height / 4, height: geo.size.height / 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .shadow(radius: 4)
                Text("Rotate Eyes")
                    .frame(width: geo.size.width * 0.55, height: geo.size.height / 10, alignment: .leading)
                    .position(x: geo.size.width * 0.63, y: geo.size.height/2)
                    .foregroundColor(.white)
                    .truncationMode(.tail)
                    .font(.system(size:15))
            }
            Group {
                Rectangle()
                    .fill(Color("dark.red.secondary"))
                    .frame(width: geo.size.width * 0.9, height: geo.size.height / 3.5, alignment: .center)
                    .cornerRadius(geo.size.height / 7)
                    .position(x: geo.size.width * 0.5, y: geo.size.height/1.25)
                Image("pan")
                    .resizable()
                    .position(x: geo.size.width * 0.05 + geo.size.height / 8 + 4, y: geo.size.height/1.25)
                    .frame(width: geo.size.height / 4, height: geo.size.height / 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .shadow(radius: 4)
                Text("Rotate Eyes")
                    .frame(width: geo.size.width * 0.55, height: geo.size.height / 10, alignment: .leading)
                    .position(x: geo.size.width * 0.63, y: geo.size.height/1.25)
                    .foregroundColor(.white)
                    .truncationMode(.tail)
                    .font(.system(size:15))
            }
            
        }
    }
    func getEmoji (streakCount: Int) -> String {
        if (streakCount <= 1) {
            return ""
        } else if (streakCount <= 6){
            return "👌"
        } else if (streakCount <= 13){
            return "🙌"
        } else if (streakCount <= 20){
            return "💪"
        } else if (streakCount <= 29){
            return "🔥"
        } else if (streakCount <= 59){
            return "🎊"
        } else if (streakCount <= 89){
            return "👑"
        } else if (streakCount <= 119){
            return "💘"
        } else if (streakCount <= 149){
            return "💕"
        } else if (streakCount <= 179){
            return "💓"
        } else {
            return "🃏"
        }
    }
}

@main
struct Habit_Widget: Widget {
    let kind: String = "Habit_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Habit_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Your habits")
        .description("Display three top habits on the home screen")
    }
}

struct Habit_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Habit_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
