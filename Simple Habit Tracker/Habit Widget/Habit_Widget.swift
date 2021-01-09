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
        SimpleEntry(date: Date(), name: "", habits: [""], icons: [""], streak: [0], doneToday: [false], configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.finale-habit-widget-cache")
        let habits = userDefaults?.stringArray(forKey: "FINALE_DEV_APP_widgetCache") ?? [""]
        let icons = userDefaults?.stringArray(forKey: "FINALE_DEV_APP_widgetCacheIcons") ?? [""]
        let name = userDefaults?.string(forKey: "FINALE_DEV_APP_widgetCacheName") ?? ""
        let streak = userDefaults?.array(forKey: "FINALE_DEV_APP_widgetCacheStreak") as! [Int]
        let doneToday = userDefaults?.array(forKey: "FINALE_DEV_APP_widgetCacheDoneTodays") as! [Bool]
        
        let entry = SimpleEntry(date: Date(), name: name, habits: habits, icons: icons, streak: streak, doneToday: doneToday, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let userDefaults = UserDefaults(suiteName: "group.finale-habit-widget-cache")
        let habits = userDefaults?.stringArray(forKey: "FINALE_DEV_APP_widgetCache") ?? [""]
        let icons = userDefaults?.stringArray(forKey: "FINALE_DEV_APP_widgetCacheIcons") ?? [""]
        let name = userDefaults?.string(forKey: "FINALE_DEV_APP_widgetCacheName") ?? ""
        let streak = userDefaults?.array(forKey: "FINALE_DEV_APP_widgetCacheStreak") as! [Int]
        let doneToday = userDefaults?.array(forKey: "FINALE_DEV_APP_widgetCacheDoneTodays") as! [Bool]

        let currentDate = Date()
        let initialEntry = SimpleEntry(date: currentDate, name: name, habits: habits, icons: icons, streak: streak, doneToday: doneToday, configuration: configuration)
        entries.append(initialEntry)
        
        let doneTodayReset = [Bool](repeating: false, count: doneToday.count)
        var streakReset = streak
        for i in 0..<streakReset.count {
            if (streakReset[i] > 0 && !doneToday[i])  {
                streakReset[i] = 0
            }
        }
        let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let resetDate = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        let resetEntry = SimpleEntry(date: resetDate, name: name, habits: habits, icons: icons, streak: streakReset, doneToday: doneTodayReset, configuration: configuration)
        entries.append(resetEntry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let habits: [String]
    let icons: [String]
    let streak: [Int]
    let doneToday: [Bool]
    let configuration: ConfigurationIntent
}

struct Habit_WidgetEntryView : View {var entry: Provider.Entry

    var body: some View {
        if (entry.habits.count != 0 || entry.icons.count != 0) {
            GeometryReader { geo in
                Rectangle()
                    .fill(Color("app.background"))
                Text("Hi, " + entry.name)
                    .frame(width: geo.size.width - 16, height: 30, alignment: .leading)
                    .font(.custom("MuktaMahee Bold",size: 25))
                    .padding(.leading, 16)
                    .padding(.top, 12)
                VStack (alignment: .leading, spacing: 6, content: {
                    ForEach(0 ..< entry.habits.count) { index in
                        HStack {
                            if (entry.doneToday[index]) {
                                Image(systemName: "checkmark.circle").resizable()
                                    .frame(width: 16, height: 16, alignment: .center)
                                    .foregroundColor(.green)
                            } else {
                                Image(entry.icons[index]).resizable()
                                    .frame(width: 16, height: 16, alignment: .center)
                                    .foregroundColor(.green)
                            }                                
                            Text(entry.habits[index])
                                .font(.system(size: 12))
                                .frame(height: 16)
                            Spacer()
                            Text(getEmoji(streakCount: entry.streak[index]))
                                .font(.system(size: 12))
                        }
                        .padding(.trailing, 16)
                    }
                })
                .frame(width: geo.size.width - 10, height: geo.size.height - 90, alignment: .topLeading)
                .padding(.leading, 16)
                .padding(.top, 48)
            }
        } else {
            GeometryReader { geo in
                Text("Add habits in the app to display them here")
                    .foregroundColor(Color(UIColor.systemGray2))
                    .multilineTextAlignment(.center)
                    .font(.system(size: 12))
                    .frame(width: geo.size.width - 20, height: geo.size.height - 20, alignment: .center)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
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
        .description("Track your habits and streaks on the home screen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Habit_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Habit_WidgetEntryView(entry: SimpleEntry(date: Date(), name: "", habits: [], icons: [], streak: [], doneToday: [], configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
