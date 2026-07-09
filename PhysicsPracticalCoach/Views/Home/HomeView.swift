//
//  HomeView.swift
//  PhysicsPracticalCoach
//
//  Replaces `HomeFragment` / `fragment_home.xml`. Shows the curriculum
//  headline, quick stats, a "Continue learning" card resolved via
//  `ContinueLearningResolver`, and quick-action entry points into each mode.
//

import SwiftUI

struct HomeView: View {
    @Bindable var homeViewModel: HomeViewModel

    private var profile: CurriculumProfile { CurriculumProfiles.forCurriculum(homeViewModel.curriculum) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                ContinueLearningCard(homeViewModel: homeViewModel, profile: profile)

                statsRow

                Text("Quick actions")
                    .font(.title3.bold())
                    .padding(.top, 4)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    NavigationLink {
                        ApparatusListView(profile: profile)
                    } label: {
                        QuickActionCard(title: "Apparatus", subtitle: "\(profile.apparatus.count) instruments", systemImage: "ruler.fill", tint: .blue)
                    }
                    NavigationLink {
                        GraphCoachListView(profile: profile)
                    } label: {
                        QuickActionCard(title: "Graph Coach", subtitle: "\(profile.graphTypes.count) graph types", systemImage: "chart.xyaxis.line", tint: .purple)
                    }
                    NavigationLink {
                        SimulationListView(profile: profile)
                    } label: {
                        QuickActionCard(title: "Simulations", subtitle: "\(profile.simulations.count) experiments", systemImage: "flask.fill", tint: .teal)
                    }
                    NavigationLink {
                        AceListView(curriculum: homeViewModel.curriculum)
                    } label: {
                        QuickActionCard(title: "ACE Practice", subtitle: "Exam technique", systemImage: "checkmark.seal.fill", tint: .orange)
                    }
                }

                curriculumSummary
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { homeViewModel.refreshStats() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(profile.homeHeadlineLine1)
                .font(.largeTitle.bold())
            Text(profile.homeHeadlineLine2)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var statsRow: some View {
        let stats = homeViewModel.userStats
        return HStack(spacing: 12) {
            StatPill(value: "\(stats.streakDays)", label: "Day streak", systemImage: "flame.fill")
            StatPill(value: "\(stats.totalPoints)", label: "Points", systemImage: "star.fill")
            StatPill(value: "\(stats.accuracyPercent)%", label: "Accuracy", systemImage: "target")
        }
    }

    private var curriculumSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(profile.examBoard) \u{00B7} \(profile.paperName)")
                .font(.headline)
            Text(profile.markingScheme)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(profile.toleranceNote)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ContinueLearningCard: View {
    let homeViewModel: HomeViewModel
    let profile: CurriculumProfile
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let target = ContinueLearningResolver.resolve(homeViewModel.userStats.lastAttempt)
        let label = ContinueLearningResolver.label(homeViewModel.userStats.lastAttempt)

        Group {
            switch target {
            case .apparatus(let type):
                NavigationLink {
                    ApparatusPracticeView(
                        apparatusType: type, curriculum: homeViewModel.curriculum,
                        repository: AttemptRepository(modelContext: modelContext),
                        onSaved: { homeViewModel.refreshStats() }
                    )
                } label: {
                    ContinueCardBody(title: "Continue: \(label)", systemImage: "arrow.forward.circle.fill")
                }
            case .graph(let type):
                NavigationLink {
                    GraphCoachPracticeView(
                        graphType: type, curriculum: homeViewModel.curriculum,
                        repository: AttemptRepository(modelContext: modelContext),
                        onSaved: { homeViewModel.refreshStats() }
                    )
                } label: {
                    ContinueCardBody(title: "Continue: \(label)", systemImage: "arrow.forward.circle.fill")
                }
            case .acePractice:
                NavigationLink {
                    AceListView(curriculum: homeViewModel.curriculum)
                } label: {
                    ContinueCardBody(title: "Continue ACE practice", systemImage: "arrow.forward.circle.fill")
                }
            case .none:
                NavigationLink {
                    ApparatusListView(profile: profile)
                } label: {
                    ContinueCardBody(title: label, systemImage: "sparkles")
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ContinueCardBody: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text("Tap to jump back in").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .foregroundStyle(.white)
    }
}

private struct StatPill: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage).foregroundStyle(.orange)
            Text(value).font(.title3.bold())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(tint)
            Text(title).font(.headline).foregroundStyle(.primary)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
