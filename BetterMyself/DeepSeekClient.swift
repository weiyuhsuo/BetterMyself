import Foundation

struct DeepSeekClient {
    private let apiKey: String
    private let url = URL(string: "https://api.deepseek.com/chat/completions")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func reflect(on entries: [DeepSeekEntryContext]) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 20
        request.httpBody = try JSONEncoder().encode(makeRequestBody(entries: entries))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DeepSeekError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8)
            throw DeepSeekError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let completion = try JSONDecoder().decode(DeepSeekCompletionResponse.self, from: data)

        guard let content = completion.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty else {
            throw DeepSeekError.emptyContent
        }

        return content
    }

    private func makeRequestBody(entries: [DeepSeekEntryContext]) -> DeepSeekCompletionRequest {
        let entryText = entries
            .sorted { $0.createdAt < $1.createdAt }
            .map { "- \(DateFormatters.entryTime(for: $0.createdAt))：\($0.content)" }
            .joined(separator: "\n")

        return DeepSeekCompletionRequest(
            model: "deepseek-v4-flash",
            messages: [
                .init(
                    role: "system",
                    content: """
                    你是 BetterMyself 里的异步回应。你的语气要安静、克制，不要像心理咨询师、老师或教练。
                    只基于用户今天写下的内容，给一段很短的回应。先看见状态，不分析过度，不诊断，不说教。
                    中文回复，80 字以内。不要使用列表，不要提出太多建议。
                    """
                ),
                .init(
                    role: "user",
                    content: """
                    这是我今天写下的记录：
                    \(entryText)

                    请给我一段克制的回应。
                    """
                )
            ],
            maxTokens: 180,
            temperature: 0.7,
            stream: false
        )
    }
}

struct DeepSeekEntryContext: Sendable {
    let createdAt: Date
    let content: String
}

struct DeepSeekCompletionRequest: Encodable {
    let model: String
    let messages: [DeepSeekMessage]
    let maxTokens: Int
    let temperature: Double
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
        case stream
    }
}

struct DeepSeekMessage: Codable {
    let role: String
    let content: String
}

struct DeepSeekCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: DeepSeekMessage
    }
}

enum DeepSeekError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case emptyContent

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "没有收到有效回应。"
        case .requestFailed(let statusCode, let message):
            if let message {
                "DeepSeek 返回 \(statusCode)：\(message)"
            } else {
                "DeepSeek 返回 \(statusCode)。"
            }
        case .emptyContent:
            "这次没有生成回应。"
        }
    }
}
