//
//  ContentView.swift
//  MeetXcode
//
//  Created by Steve Handy on 2026.06.01.
//

import SwiftUI
import MapKit

struct ContentView: View {
    // MARK: - Map State
    private let centerCoordinate = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090) // Apple Park area
    @State private var cameraPosition: MapCameraPosition

    // MARK: - Filter State
    private let allCategories: [String] = ["Outdoors", "Urban", "Water", "Night", "Family"]
    private let allEfforts: [String] = ["Easy", "Moderate", "Challenging"]

    @State private var selectedCategories: Set<String> = []
    @State private var selectedEfforts: Set<String> = []
    @State private var showingFilters: Bool = false

    // MARK: - Sample Adventure State
    @State private var adventureTitle: String = "Sunset Ridge Walk"
    @State private var adventureDescription: String = "A quick loop up to a ridge with panoramic views. Perfect for an after-work micro adventure."
    @State private var adventureCategory: String = "Outdoors"
    @State private var adventureEffort: String = "Easy"
    @State private var adventureComplete: Bool = false

    init() {
        let region = MKCoordinateRegion(center: centerCoordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        _cameraPosition = State(initialValue: .region(region))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $cameraPosition) {
                    Marker("Start", coordinate: centerCoordinate)
                }
                .ignoresSafeArea()

                // Floating info card below the title
                VStack {
                    // Spacer to place the card below the navigation bar
                    Color.clear.frame(height: 12)
                    InfoCard(
                        category: adventureCategory,
                        effort: adventureEffort,
                        title: adventureTitle,
                        description: adventureDescription,
                        isComplete: adventureComplete,
                        onToggleComplete: { adventureComplete.toggle() }
                    )
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 8)

                // Floating bottom action button
                VStack {
                    Spacer()
                    Button {
                        // TODO: Load the next adventure
                    } label: {
                        Label("Next Adventure", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Micro Adventures")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilters = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .help("Filter by category and effort")
                }
            }
            .sheet(isPresented: $showingFilters) {
                NavigationStack {
                    FilterView(
                        allCategories: allCategories,
                        allEfforts: allEfforts,
                        selectedCategories: $selectedCategories,
                        selectedEfforts: $selectedEfforts
                    )
                    .navigationTitle("Filters")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Clear") {
                                selectedCategories.removeAll()
                                selectedEfforts.removeAll()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingFilters = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - Filter View
private struct FilterView: View {
    let allCategories: [String]
    let allEfforts: [String]
    @Binding var selectedCategories: Set<String>
    @Binding var selectedEfforts: Set<String>

    var body: some View {
        List {
            Section(header: Text("Categories")) {
                Toggle(isOn: Binding(
                    get: { selectedCategories.count == allCategories.count && !allCategories.isEmpty },
                    set: { newValue in
                        if newValue { selectedCategories = Set(allCategories) } else { selectedCategories.removeAll() }
                    }
                )) {
                    Text("Select All")
                }
                ForEach(allCategories, id: \.self) { category in
                    MultipleSelectRow(title: category, isSelected: selectedCategories.contains(category)) {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }
                }
            }

            Section(header: Text("Effort Levels")) {
                Toggle(isOn: Binding(
                    get: { selectedEfforts.count == allEfforts.count && !allEfforts.isEmpty },
                    set: { newValue in
                        if newValue { selectedEfforts = Set(allEfforts) } else { selectedEfforts.removeAll() }
                    }
                )) {
                    Text("Select All")
                }
                ForEach(allEfforts, id: \.self) { effort in
                    MultipleSelectRow(title: effort, isSelected: selectedEfforts.contains(effort)) {
                        if selectedEfforts.contains(effort) {
                            selectedEfforts.remove(effort)
                        } else {
                            selectedEfforts.insert(effort)
                        }
                    }
                }
            }
        }
    }
}

private struct MultipleSelectRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct InfoCard: View {
    let category: String
    let effort: String
    let title: String
    let description: String
    let isComplete: Bool
    let onToggleComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Pills row
            HStack(spacing: 8) {
                Pill(text: category, systemImage: "leaf")
                Pill(text: effort, systemImage: "figure.walk")
                Spacer()
            }

            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack {
                Spacer()
                Button {
                    onToggleComplete()
                } label: {
                    Label(isComplete ? "Completed" : "Mark Complete", systemImage: isComplete ? "checkmark.circle.fill" : "circle")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
    }
}

private struct Pill: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
    }
}

#Preview {
    ContentView()
}
