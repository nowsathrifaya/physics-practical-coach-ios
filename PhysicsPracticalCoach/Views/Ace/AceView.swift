//
//  AceView.swift
//  PhysicsPracticalCoach
//
//  Replaces `AceListFragment` + `AceDetailFragment`. Reveal-answer study
//  flow: read the exam question, attempt it mentally/on paper, then reveal
//  the model answer, common mistakes, and examiner tip.
//

import SwiftUI

struct AceListView: View {
    let curriculum: Curriculum
    @State private var selectedTopic: AceTopic?

    private var questions: [AceQuestion] { AceQuestionBank.forCurriculum(curriculum) }
    private var groupedByTopic: [(AceTopic, [AceQuestion])] {
        Dictionary(grouping: questions, by: \.topic)
            .sorted { $0.key.label < $1.key.label }
    }

    var body: some View {
        List {
            ForEach(groupedByTopic, id: \.0) { topic, topicQuestions in
                Section(topic.label) {
                    ForEach(topicQuestions) { question in
                        NavigationLink {
                            AceDetailView(question: question)
                        } label: {
                            AceRow(question: question)
                        }
                    }
                }
            }
        }
        .navigationTitle("ACE Practice")
    }
}

private struct AceRow: View {
    let question: AceQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question.questionText)
                .font(.subheadline)
                .lineLimit(2)
            HStack(spacing: 8) {
                Text(question.skillArea.label)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(question.skillArea.colour.opacity(0.15), in: Capsule())
                    .foregroundStyle(question.skillArea.colour)
                Text("\(question.marks) mark\(question.marks == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AceDetailView: View {
    let question: AceQuestion
    @State private var revealed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    Text(question.skillArea.label)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(question.skillArea.colour.opacity(0.15), in: Capsule())
                        .foregroundStyle(question.skillArea.colour)
                    Text("\(question.marks) mark\(question.marks == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(question.questionText)
                    .font(.body)

                if revealed {
                    AceInfoBlock(title: "Model answer", text: question.modelAnswer, tint: .green)
                    AceInfoBlock(title: "Common mistakes", text: question.commonMistakes, tint: .red)
                    AceInfoBlock(title: "Examiner tip", text: question.examinerTip, tint: .orange)
                } else {
                    Button("Reveal model answer") { withAnimation { revealed = true } }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(question.topic.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AceInfoBlock: View {
    let title: String
    let text: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(tint)
            Text(text).font(.subheadline)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
