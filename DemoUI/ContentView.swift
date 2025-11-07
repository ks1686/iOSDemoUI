import Combine
import SwiftUI

// Top-level model used by the list
struct DemoItem: Identifiable, Codable {
  let id: Int
  let title: String
}

final class DemoData: ObservableObject {
  @Published var items: [DemoItem] = []

  init() {
    load()
  }

  func load() {
    // Looks for a bundled JSON file named "demo_items.json"
    if let url = Bundle.main.url(forResource: "demo_items", withExtension: "json") {
      do {
        let data = try Data(contentsOf: url)
        items = try JSONDecoder().decode([DemoItem].self, from: data)
      } catch {
        print("Failed to decode demo_items.json: \(error)")
        items = Self.fallback
      }
    } else {
      print("demo_items.json not found in bundle; using fallback")
      items = Self.fallback
    }
  }

  // Fallback so the app still works if the JSON file is missing or invalid
  private static let fallback: [DemoItem] = (1...20).map { DemoItem(id: $0, title: "Item \($0)") }
}

struct ContentView: View {
  @State private var name: String = ""
  @State private var isOn: Bool = false
  @State private var sliderValue: Double = 50
  @State private var stepperValue: Int = 1
  @State private var selectedFruit: String = "Apple"
  @State private var showAlert: Bool = false
  @State private var progress: Double = 0.3
  @State private var date: Date = .now

  let fruits = ["Apple", "Banana", "Cherry", "Grape"]

  var body: some View {
    NavigationStack {
      Form {
        Section("Text & Input") {
          TextField("Enter your name", text: $name)
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)

          Button("Say Hello") {
            showAlert = true
          }
          .alert("Hello, \(name.isEmpty ? "there" : name)!", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
          }
        }

        Section("Toggles & Pickers") {
          Toggle("Enable Feature", isOn: $isOn)
          Slider(value: $sliderValue, in: 0...100, step: 1)
          Stepper("Quantity: \(stepperValue)", value: $stepperValue, in: 1...10)

          // Dropdown-like control in SwiftUI is a Picker
          Picker("Favorite Fruit", selection: $selectedFruit) {
            ForEach(fruits, id: \.self) { Text($0) }
          }
        }

        Section("Feedback") {
          ProgressView(value: progress)
          Button("Advance Progress") {
            progress = min(1.0, progress + 0.1)
          }
          Button("Regress Progress") {
            progress = max(0.0, progress - 0.1)
          }
          DatePicker("Reminder", selection: $date, displayedComponents: [.date, .hourAndMinute])
        }

        Section("Images & Lists") {
          HStack {
            Image(systemName: "bolt.fill")
            Text("System Symbol Image")
          }
          NavigationLink("Go to List Screen") {
            DemoListView()
          }
        }
      }
      .navigationTitle("Demo Controls")
    }
  }
}

struct DemoListView: View {
  @StateObject private var store = DemoData()

  var body: some View {
    List(store.items) { item in
      Text(item.title)
    }
    .navigationTitle("List")
  }
}

#Preview {
  ContentView()
}
