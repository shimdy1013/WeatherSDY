//
//  WeatherService.swift
//  WeatherSDY
//
//  Created by 심두용 on 2022/07/05.
//

import Foundation

// 에러 정의
enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
}

class WeatherService {
    // .plist에서 API Key 가져오기
    private var apiKey: String {    // 연산 프로퍼티
        get {   // getter
            // 생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: "APIKey", ofType: "plist") else {
                fatalError("Couldn't find file 'APIKey.plist'.")
            }
            
            // .plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 값 찾기
            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'APIKey.plist'.")
            }
            return value
        }
    }
    
    // 현재 날씨
    func getCurrentWeather(regionID: Int = 1835847, completion: @escaping (Result<WeatherResponse, NetworkError>) -> Void) {
        
        // 1. URL - API 호출을 위한 URL
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?id=\(regionID)&appid=\(apiKey)&units=metric")
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        // 2. URLSession 만들고 task 주기
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            
            // Data 타입으로 받은 리턴을 디코드
            let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data)

            // 성공
            if let weatherResponse = weatherResponse {
                print(weatherResponse)
                completion(.success(weatherResponse)) // 성공한 데이터 저장
            } else {
                completion(.failure(.decodingError))
            }
        }.resume() // 3. dataTask 시작
    }
}
