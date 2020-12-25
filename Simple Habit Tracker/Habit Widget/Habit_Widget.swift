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
    var habits = ["Rotate eyes", "Kiss QQ"]
    
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color("app.background"))
            Text("Hi, Grant")
                .frame(width: geo.size.width - 10, height: 30, alignment: .leading)
                .position(x: 95, y: geo.size.width/7)
                .font(.custom("MuktaMahee Bold",size: 25))
            VStack (alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                ForEach(0 ..< habits.count) { index in
                    Text(habits[index])
                        .font(.system(size: 12))
                }
            })
            .frame(width: geo.size.width - 10, height: geo.size.height - 80, alignment: .topLeading)
            .position(x: 95, y: geo.size.width/2)
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
