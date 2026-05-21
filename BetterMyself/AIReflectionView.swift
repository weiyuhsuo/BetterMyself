import SwiftUI

struct AIReflectionView: View {
    let entries: [Entry]
    let trigger: Int

    @State private var apiKey = ""
    @State private var draftAPIKey = ""
    @State private var reflection: String?
    @State private var errorMessage: String?
    @State private var isAPIKeyEditorShown = false
    @State private var isSavingKey = false
    @State private var isLoading = false
    @State private var lastHandledTrigger = 0

    private var hasEntries: Bool {
        !entries.isEmpty
    }

    private var canAskAI: Bool {
        hasEntries && !apiKey.isEmpty && !isLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let reflection {
                Text(reflection)
                    .font(.footnote)
                    .lineSpacing(4)
                    .foregroundStyle(Color.betterText)
                    .id(reflection)
                    .transition(.opacity)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Color.betterSecondaryText)
            }

            VStack(alignment: .leading, spacing: 10) {
                Button(apiKey.isEmpty ? "设置 DeepSeek API Key" : "更换 DeepSeek API Key") {
                    isAPIKeyEditorShown.toggle()
                }
                .font(.caption)
                .foregroundStyle(Color.betterSecondaryText)

                if isAPIKeyEditorShown {
                    SecureField("DeepSeek API Key", text: $draftAPIKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.betterBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                    HStack {
                        Text("测试用，只保存在本机 Keychain")
                            .font(.caption)
                            .foregroundStyle(Color.betterSecondaryText)

                        Spacer()

                        Button(isSavingKey ? "保存中" : "保存") {
                            saveAPIKey()
                        }
                        .font(.caption.weight(.medium))
                        .disabled(draftAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSavingKey)
                    }
                }
            }
        }
        .frame(maxWidth: 520, alignment: .leading)
        .task {
            apiKey = APIKeyStore.load()
        }
        .onChange(of: trigger) { _, newValue in
            guard newValue != lastHandledTrigger else { return }
            lastHandledTrigger = newValue

            Task {
                await askAI()
            }
        }
    }

    private func saveAPIKey() {
        let key = draftAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }

        isSavingKey = true
        errorMessage = nil

        do {
            try APIKeyStore.save(key)
            apiKey = key
            draftAPIKey = ""
            isAPIKeyEditorShown = false

            if hasEntries {
                Task {
                    await askAI()
                }
            }
        } catch {
            errorMessage = "API Key 没有保存成功。"
        }

        isSavingKey = false
    }

    private func askAI() async {
        guard canAskAI else { return }

        let entryContexts = entries.map {
            DeepSeekEntryContext(createdAt: $0.createdAt, content: $0.content)
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await DeepSeekClient(apiKey: apiKey).reflect(on: entryContexts)
            withAnimation(.easeInOut(duration: 0.35)) {
                reflection = response
            }
        } catch {
            errorMessage = displayMessage(for: error)
        }

        isLoading = false
    }

    private func displayMessage(for error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                return "DeepSeek 响应超时。可以稍后再试，或检查当前网络。"
            case NSURLErrorNotConnectedToInternet:
                return "当前没有网络连接。"
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                return "无法连接到 DeepSeek。"
            default:
                return "网络请求失败（\(nsError.code)）。"
            }
        }

        return error.localizedDescription
    }
}

#Preview {
    AIReflectionView(entries: [Entry(content: "今天挺开心的")], trigger: 1)
        .padding()
}
