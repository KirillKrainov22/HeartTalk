import Foundation

enum QuestionLoaderError: Error {
    case fileNotFound
    case emptyData
    case underlying(Error)
}

protocol QuestionLoading {
    func load(completion: @escaping (Result<[Question], QuestionLoaderError>) -> Void)
}

final class QuestionLoader: QuestionLoading {

    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "questions") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load(completion: @escaping (Result<[Question], QuestionLoaderError>) -> Void) {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            completion(.failure(.fileNotFound))
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<[Question], QuestionLoaderError>
            do {
                let data = try Data(contentsOf: url)
                guard !data.isEmpty else {
                    result = .failure(.emptyData)
                    DispatchQueue.main.async { completion(result) }
                    return
                }
                let questions = try JSONDecoder().decode([Question].self, from: data)
                result = .success(questions)
            } catch {
                result = .failure(.underlying(error))
            }
            DispatchQueue.main.async { completion(result) }
        }
    }
}
