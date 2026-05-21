import SwiftData
import SwiftUI

struct ComposeView: View {
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isInputFocused: Bool

    @State private var text = ""
    @State private var editorHeight: CGFloat = 104
    @State private var feedback: String?
    @State private var feedbackTask: Task<Void, Never>?

    private let feedbackMessages = ["收好了", "放在这里了", "嗯，我记下来了"]
    private let minEditorHeight: CGFloat = 104
    private let maxEditorHeight: CGFloat = 260

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedText.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.betterBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    Text("Hi，你今天想说点什么？")
                        .font(.title2.weight(.regular))
                        .foregroundStyle(Color.betterText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)

                    VStack(spacing: 10) {
                        inputBox

                        HStack(alignment: .center, spacing: 12) {
                            if let feedback {
                                Text(feedback)
                                    .font(.footnote)
                                    .foregroundStyle(Color.betterSecondaryText)
                                    .transition(.opacity)
                            }

                            Spacer(minLength: 0)

                            Button(action: saveEntry) {
                                Text("说完了")
                                    .font(.footnote.weight(.medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                            }
                            .foregroundStyle(canSave ? Color.betterBackground : Color.betterSecondaryText)
                            .background(canSave ? Color.betterPrimary : Color.betterStroke.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .disabled(!canSave)
                        }
                    }
                    .padding(.top, 42)
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 28)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(250))
            isInputFocused = true
        }
    }

    private var inputBox: some View {
        TextEditor(text: $text)
            .focused($isInputFocused)
            .scrollContentBackground(.hidden)
            .font(.body)
            .lineSpacing(5)
            .padding(.top, 12)
            .padding(.leading, 14)
            .padding(.trailing, 14)
            .padding(.bottom, 12)
            .frame(height: editorHeight)
            .background(Color.betterSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.betterStroke, lineWidth: 0.7)
            }
            .background(alignment: .topLeading) {
                Text(text.isEmpty ? " \n \n " : text)
                    .font(.body)
                    .lineSpacing(5)
                    .padding(.top, 20)
                    .padding(.leading, 19)
                    .padding(.trailing, 19)
                    .padding(.bottom, 18)
                    .opacity(0)
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    updateEditorHeight(proxy.size.height)
                                }
                                .onChange(of: text) {
                                    updateEditorHeight(proxy.size.height)
                                }
                        }
                    }
            }
            .frame(maxWidth: 520)
            .animation(.easeOut(duration: 0.18), value: editorHeight)
    }

    private func saveEntry() {
        let content = trimmedText
        guard !content.isEmpty else { return }

        modelContext.insert(Entry(content: content))

        do {
            try modelContext.save()
            text = ""
            showFeedback()
            isInputFocused = true
        } catch {
            feedback = "先放一放，刚才没有存好"
        }
    }

    private func showFeedback() {
        feedbackTask?.cancel()

        withAnimation(.easeOut(duration: 0.22)) {
            feedback = feedbackMessages.randomElement()
        }

        feedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.22)) {
                    feedback = nil
                }
            }
        }
    }

    private func updateEditorHeight(_ measuredHeight: CGFloat) {
        let nextHeight = min(max(measuredHeight, minEditorHeight), maxEditorHeight)

        guard abs(editorHeight - nextHeight) > 1 else { return }
        editorHeight = nextHeight
    }
}

#Preview {
    ComposeView()
        .modelContainer(for: Entry.self, inMemory: true)
}
