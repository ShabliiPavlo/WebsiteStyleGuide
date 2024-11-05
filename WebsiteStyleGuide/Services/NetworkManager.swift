//
//  NetworkManager.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.

import Foundation
import Network

class NetworkManager {
    
    // MARK: - Properties
    
    static let shared = NetworkManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    // MARK: - Initializer
    
    private init() {
        monitor.start(queue: queue)
    }
    
    // MARK: - Connection Methods
    
    func checkConnection(completion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }
    }
    
    // MARK: - Token Handling Methods
    
    func getToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1/token") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Данные отсутствуют"])))
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                print("Полученный токен: \(tokenResponse.token)")
                DispatchQueue.main.async {
                    completion(.success(tokenResponse.token))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - User Fetching Methods
    
    func fetchUsers(page: Int, completion: @escaping (Result<UsersResponse, Error>) -> Void) {
        let urlString = "https://frontend-test-assignment-api.abz.agency/api/v1/users?page=\(page)&count=6"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Ошибка HTTP: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Данные отсутствуют"])))
                }
                return
            }
            
            do {
                let usersResponse = try JSONDecoder().decode(UsersResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(usersResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - User Registration Methods
    
    func registerUser(name: String, email: String, phone: String, positionId: Int, photoData: Data, completion: @escaping (Result<User, Error>) -> Void) {
        getToken { [weak self] result in
            switch result {
            case .success(let token):
                self?.performUserRegistration(name: name, email: email, phone: phone, positionId: positionId, photoData: photoData, token: token, completion: completion)
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func performUserRegistration(name: String, email: String, phone: String, positionId: Int, photoData: Data, token: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1/users") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Token")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createRequestBody(boundary: boundary, name: name, email: email, phone: phone, positionId: positionId, photoData: photoData)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP-код ответа: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 201 {
                    let tempUser = User(id: 0, name: name, email: email, phone: phone, position: "Position \(positionId)", photo: "Placeholder URL")
                    DispatchQueue.main.async {
                        completion(.success(tempUser))
                    }
                    return
                } else if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"])))
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Данные отсутствуют"])))
                }
                return
            }
            
            do {
                let userResponse = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(userResponse))
                }
            } catch {
                print("Ошибка при декодировании: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Helper Methods
    
    private func createRequestBody(boundary: String, name: String, email: String, phone: String, positionId: Int, photoData: Data) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(email)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"phone\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(phone)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"position_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(positionId)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(photoData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
