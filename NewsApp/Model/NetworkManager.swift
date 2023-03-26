//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Luis Filipe Alves de Oliveira on 14/03/23.
//

import Foundation

enum ResultNewsError: Error {
    case badURL, noData, invalidJson
}


class NetwotkManager {
    static let shared = NetwotkManager()

    struct Constants {
        static let api = URL(string: "https://ebacnewsapp.herokuapp.com/home")
    }

    private init() {}

    func getNews(completion: @escaping (Result<[ResultNews], ResultNewsError>) -> Void) {
        guard let url = Constants.api else {
            completion(.failure(.badURL))
            return
        }

        let configuration = URLSessionConfiguration.default

        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(.failure(.invalidJson))
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ResponseElement.self, from: data)
                completion(.success(result.home.results))
            } catch {
                print("Error info: \(error.localizedDescription)")
                completion(.failure(.noData))
            }
        }

        task.resume()
    }



}
