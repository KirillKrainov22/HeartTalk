import Foundation
import NaturalLanguage
import CoreML

final class NLPService {
    static let shared = NLPService()

    private var model: NLModel?

    private init() {
        loadModel()
    }

    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuOnly
            if let modelURL = Bundle.main.url(forResource: "NLP", withExtension: "mlmodelc") ?? compileModel() {
                let mlModel = try MLModel(contentsOf: modelURL, configuration: config)
                model = try NLModel(mlModel: mlModel)
            }
        } catch {
            print("NLP model load error: \(error)")
        }
    }

    private func compileModel() -> URL? {
        guard let sourceURL = Bundle.main.url(forResource: "NLP", withExtension: "mlmodel") else { return nil }
        return try? MLModel.compileModel(at: sourceURL)
    }

    enum Sentiment: String {
        case positive = "positive"
        case neutral = "neutral"
        case negative = "negative"

        var displayName: String {
            switch self {
            case .positive: return "Позитив"
            case .neutral: return "Нейтрально"
            case .negative: return "Негатив"
            }
        }
    }

    func classify(_ text: String) -> Sentiment {
        guard let model = model, !text.isEmpty else { return .neutral }
        let label = model.predictedLabel(for: text) ?? "neutral"
        return Sentiment(rawValue: label) ?? .neutral
    }

    struct SentimentStats {
        let positive: Double
        let neutral: Double
        let negative: Double
    }

    func analyzeNotes(_ notes: [String]) -> SentimentStats {
        guard !notes.isEmpty else {
            return SentimentStats(positive: 0, neutral: 0, negative: 0)
        }

        var pos = 0, neu = 0, neg = 0
        for note in notes {
            switch classify(note) {
            case .positive: pos += 1
            case .neutral: neu += 1
            case .negative: neg += 1
            }
        }

        let total = Double(notes.count)
        return SentimentStats(
            positive: Double(pos) / total * 100,
            neutral: Double(neu) / total * 100,
            negative: Double(neg) / total * 100
        )
    }
}
