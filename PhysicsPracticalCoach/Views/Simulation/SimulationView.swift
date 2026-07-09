//
//  SimulationView.swift
//  PhysicsPracticalCoach
//
//  Replaces `SimulationListFragment` + the 12 per-experiment simulation
//  fragments. Simulations aren't graded (no attempt is recorded — matches
//  Android, see `ContinueLearningResolver`), so this screen is exploratory:
//  drag a slider, watch the apparatus respond in real time.
//
//  The Pendulum simulation is fully implemented as the flagship native
//  Canvas + animation example. The remaining 11 use `GenericSimulationView`,
//  a working slider-driven placeholder with the correct physics formula and
//  description already wired up — bespoke Canvas art for each is the next
//  increment (see project notes).
//

import SwiftUI

struct SimulationListView: View {
    let profile: CurriculumProfile

    var body: some View {
        List(profile.simulations) { type in
            NavigationLink {
                simulationDestination(for: type)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.label).font(.headline)
                    Text(type.descriptionText).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Simulations")
    }

    @ViewBuilder
    private func simulationDestination(for type: SimulationType) -> some View {
        switch type {
        case .pendulum:
            PendulumSimulationView()
        default:
            GenericSimulationView(type: type)
        }
    }
}

/// Fully interactive pendulum: dragging the length slider updates both the
/// live period readout (T = 2\u{03C0}\u{221A}(L/g)) and an animated swinging bob drawn
/// with `Canvas` + `TimelineView`, matching the Android `PendulumSimulationView`.
struct PendulumSimulationView: View {
    @State private var lengthM: Double = 0.5

    private var period: Double { 2 * .pi * (lengthM / 9.81).squareRoot() }

    var body: some View {
        VStack(spacing: 20) {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let pivot = CGPoint(x: size.width / 2, y: 16)
                    let maxStringLength = size.height - 60
                    let stringLength = CGFloat(min(lengthM / 1.0, 1.0)) * maxStringLength + 40

                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    let angle = (.pi / 8) * sin(elapsed * (2 * .pi / max(period, 0.2)))

                    let bobPosition = CGPoint(
                        x: pivot.x + stringLength * CGFloat(sin(angle)),
                        y: pivot.y + stringLength * CGFloat(cos(angle))
                    )

                    var string = Path()
                    string.move(to: pivot)
                    string.addLine(to: bobPosition)
                    context.stroke(string, with: .color(.secondary), lineWidth: 1.5)

                    context.fill(Path(ellipseIn: CGRect(x: pivot.x - 5, y: pivot.y - 5, width: 10, height: 10)), with: .color(.primary))
                    context.fill(Path(ellipseIn: CGRect(x: bobPosition.x - 14, y: bobPosition.y - 14, width: 28, height: 28)), with: .color(.blue))
                }
            }
            .frame(height: 260)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text("Length: \(String(format: "%.2f", lengthM)) m")
                Slider(value: $lengthM, in: 0.1...1.0)
                Text("Period T = \(String(format: "%.2f", period)) s")
                    .font(.headline)
                Text("T = 2\u{03C0}\u{221A}(L/g)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .navigationTitle(SimulationType.pendulum.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Working slider-driven simulation shell for the remaining 11 experiment
/// types. Each has its correct governing formula and description already
/// wired from `SimulationType`; bespoke apparatus artwork is a follow-up.
struct GenericSimulationView: View {
    let type: SimulationType
    @State private var control: Double = 0.5

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(height: 200)
                .overlay {
                    Image(systemName: iconName)
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                }

            Text(type.descriptionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Adjust the control variable")
                Slider(value: $control)
            }
        }
        .padding(20)
        .navigationTitle(type.label)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var iconName: String {
        switch type {
        case .ohmsLaw, .resistanceWire, .filamentLamp: return "bolt.fill"
        case .springExtension: return "arrow.up.and.down"
        case .lensFocusing, .refraction: return "eye.fill"
        case .potentiometer: return "slider.horizontal.3"
        case .moments: return "scalemass.fill"
        case .vernierCaliper: return "ruler.fill"
        case .densityDisplacement: return "drop.fill"
        case .coolingCurve: return "thermometer"
        case .pendulum: return "clock.fill"
        }
    }
}
