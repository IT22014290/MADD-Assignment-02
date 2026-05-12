import SwiftUI

// MARK: - Avatar View

struct ChildAvatarView: View {
    let initials: String
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(initials)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel(text)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = NurseryTheme.textPrimary

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(NurseryTheme.textSecondary)
                .frame(width: 140, alignment: .leading)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 14))
                .foregroundStyle(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionLabel: String = "Add"

    var body: some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()
            Spacer()
            if let action = action {
                Button(actionLabel, action: action)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NurseryTheme.primary)
            }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(NurseryTheme.primary.opacity(0.4))
                .accessibilityHidden(true)
            Text(title)
                .font(.headline)
                .foregroundStyle(NurseryTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(NurseryTheme.textSecondary)
                .multilineTextAlignment(.center)
            if let title = buttonTitle, let action = buttonAction {
                Button(title, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 200)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(NurseryTheme.textPrimary)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Allergen Tag

struct AllergenTag: View {
    let allergen: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
                .accessibilityHidden(true)
            Text(allergen)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(NurseryTheme.red)
        .clipShape(Capsule())
        .accessibilityLabel("Allergen: \(allergen)")
    }
}

// MARK: - Mood Picker

struct MoodRatingPicker: View {
    @Binding var rating: String
    let ratings = ["😢", "😕", "😐", "🙂", "😄"]
    let labels = ["Upset", "Unsettled", "Okay", "Happy", "Very Happy"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(ratings.enumerated()), id: \.offset) { idx, emoji in
                Button {
                    rating = labels[idx]
                } label: {
                    VStack(spacing: 4) {
                        Text(emoji)
                            .font(.system(size: 28))
                            .scaleEffect(rating == labels[idx] ? 1.2 : 1.0)
                        Text(labels[idx])
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(rating == labels[idx] ? NurseryTheme.primary : NurseryTheme.textSecondary)
                    }
                }
                .animation(.spring(response: 0.3), value: rating)
                .accessibilityLabel("Mood: \(labels[idx])")
                .accessibilityAddTraits(rating == labels[idx] ? .isSelected : [])
                .accessibilityHint("Tap to set child's mood as \(labels[idx])")
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Mood rating. Current: \(rating.isEmpty ? "Not set" : rating)")
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.3)
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
