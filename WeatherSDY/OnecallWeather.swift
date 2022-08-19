//
//  OnecallWeather.swift
//  WeatherSDY
//
//  Created by 심두용 on 2022/08/03.
//

import Foundation

struct OneWeatherResponse: Decodable {
    let hourly: [Hourly]
}

struct Hourly: Decodable {
    let dt: Int   // 시간
    let temp: Double   // 온도
    let pop: Double     // 강수확률
    let weather: [OneWeather]
}

struct OneWeather: Decodable {
    let icon: String    // 아이콘
    let main: String
    let description: String
}
