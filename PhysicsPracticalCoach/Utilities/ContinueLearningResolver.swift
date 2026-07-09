//
//  ContinueLearningResolver.swift
//  PhysicsPracticalCoach
//
//  Port of `domain.stats.ContinueLearningResolver.kt`. Simulations aren't
//  graded, so they never appear in the attempts table — "Continue Learning"
//  and "Last Experiment" can only ever resolve to Apparatus, Graph, or ACE
//  practice, which matches what's actually recorded.
//

import Foundation

enum ContinueTarget: Hashable {
    case apparatus(ApparatusType)
    case graph(GraphCoachType)
    case acePractice
    case none
}

enum ContinueLearningResolver {
    static func resolve(_ attempt: Attempt?) -> ContinueTarget {
        guard let attempt else { return .none }
        switch attempt.mode {
        case AttemptMode.apparatusPractice.rawValue:
            if let type = ApparatusType.allCases.first(where: { $0.label == attempt.target }) {
                return .apparatus(type)
            }
            return .none
        case AttemptMode.graphCoach.rawValue:
            if let type = GraphCoachType.allCases.first(where: { $0.label == attempt.target }) {
                return .graph(type)
            }
            return .none
        case "ACE_PRACTICE", "MOCK_EXAM":
            return .acePractice
        default:
            return .none
        }
    }

    /// Short label for the "Continue Learning: <this>" / "Last: <this>" CTA text.
    static func label(_ attempt: Attempt?) -> String {
        guard let attempt else { return "Start your first experiment" }
        return attempt.target
    }
}
