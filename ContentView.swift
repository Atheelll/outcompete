//
//  ContentView.swift
//  apple sport
//
//  Created by atheer al on 11/10/1446 AH.
//

//  ContentView.swift
import SwiftUI

struct Competition: Identifiable, Equatable {
    let id: UUID
    let title: String
    let date: String
    let competitors: Int
    let color: Color
    let imageName: String
    var isJoined: Bool
    let isExpired: Bool
}

@MainActor class CompetitionsViewModel: ObservableObject {
    @Published var allCompetitions: [Competition] = [
        Competition(id: UUID(), title: "Running", date: "6/08 10:30", competitors: 215, color: .red, imageName: "running", isJoined: false, isExpired: false),
        Competition(id: UUID(), title: "Football", date: "17/08 09:30", competitors: 100, color: .green, imageName: "football", isJoined: false, isExpired: false),
        Competition(id: UUID(), title: "Volleyball", date: "3/08 10:30", competitors: 20, color: .yellow, imageName: "volleyball", isJoined: false, isExpired: false),
        Competition(id: UUID(), title: "Swimming", date: "11/08 10:00", competitors: 10, color: .blue, imageName: "swimming", isJoined: false, isExpired: false)
    ]

    @Published var myCompetitions: [Competition] = [
        Competition(id: UUID(), title: "Running", date: "6/08 10:30", competitors: 215, color: .red, imageName: "running", isJoined: true, isExpired: false)
    ]

    @Published var showSuccessMessage = false

    func joinCompetition(_ competition: Competition) {
        guard let index = allCompetitions.firstIndex(where: { $0.id == competition.id }) else { return }

        if !myCompetitions.contains(where: { $0.id == competition.id }) {
            allCompetitions[index].isJoined = true
            myCompetitions.append(allCompetitions[index])
            showSuccessMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.showSuccessMessage = false
                }
            }
        }
    }
}

struct CompetitionCard: View {
    let competition: Competition
    var showAddIcon: Bool
    var onAdd: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(competition.color.opacity(0.9))
                .frame(height: 130)
                .shadow(radius: 4)
                .overlay(
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(competition.title)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            Text("competition start - \(competition.date)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            Text("Number of competitors - \(competition.competitors)")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                        if showAddIcon && !competition.isJoined {
                            Button(action: {
                                onAdd?()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                        Image(competition.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding()
                )
        }
    }
}

struct CompetitionsView: View {
    @ObservedObject var viewModel: CompetitionsViewModel

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.allCompetitions) { comp in
                            CompetitionCard(competition: comp, showAddIcon: true) {
                                viewModel.joinCompetition(comp)
                            }
                        }
                    }
                    .padding()
                }
                if viewModel.showSuccessMessage {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Added successfully!")
                                .padding()
                                .background(Color.green.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.trailing)
                        }
                        Spacer()
                    }
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: viewModel.showSuccessMessage)
                }
            }
            .navigationTitle("competitions")
        }
    }
}

struct MyCompetitionsView: View {
    @ObservedObject var viewModel: CompetitionsViewModel

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.myCompetitions) { comp in
                            CompetitionCard(competition: comp, showAddIcon: false)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My competitions")
        }
    }
}

struct CustomTabBarItem: View {
    let systemImage: String
    let isSelected: Bool

    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: isSelected ? 30 : 26, height: isSelected ? 30 : 26)
                .foregroundColor(isSelected ? .white : .gray.opacity(0.5))
                .padding(12)
                .background(
                    isSelected ? Color.white.opacity(0.2) : Color.clear
                )
                .clipShape(Circle())
                .shadow(color: isSelected ? .white.opacity(0.3) : .clear, radius: 5, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView: View {
    @StateObject var viewModel = CompetitionsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Group {
                    switch selectedTab {
                    case 0:
                        CompetitionsView(viewModel: viewModel)
                            .transition(.opacity)
                    case 1:
                        MyCompetitionsView(viewModel: viewModel)
                            .transition(.opacity)
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: selectedTab)
            }

            HStack(spacing: 0) {
                Button(action: {
                    selectedTab = 0
                }) {
                    CustomTabBarItem(systemImage: "person.3", isSelected: selectedTab == 0)
                }
                Button(action: {
                    selectedTab = 1
                }) {
                    CustomTabBarItem(systemImage: "person", isSelected: selectedTab == 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(.horizontal)
                    .shadow(radius: 10)
            )
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    ContentView()
}
