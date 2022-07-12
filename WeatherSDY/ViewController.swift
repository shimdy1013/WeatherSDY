//
//  ViewController.swift
//  WeatherSDY
//
//  Created by 심두용 on 2022/07/02.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxminTempLabel: UILabel!
    @IBOutlet weak var localName: UILabel!
    @IBOutlet weak var feelLikeLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    
    
    // 받아온 데이터를 저장할 프로퍼티
    var weather: Weather?
    var main: Main?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // data fetch
        WeatherService().getWeather { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.weather = weatherResponse.weather.first
                    self.main = weatherResponse.main
                    self.name = weatherResponse.name
                    self.setWeatherUI()
                    self.getDayTime()
                }
            case .failure(_ ):
                print("error")
            }
        }
    }
    
    private func setWeatherUI() {
        let url = URL(string: "https://openweathermap.org/img/wn/\(self.weather?.icon ?? "00")@2x.png")
        let data = try? Data(contentsOf: url!)
        if let data = data {
            iconImageView.image = UIImage(data: data)
        }
        
        guard var temp = main?.temp else { return }
        temp = roundTempDecimal(value: temp)
        tempLabel.text = "\(temp)º"
        
        guard var maxTemp = main?.temp_max, var minTemp = main?.temp_min else { return }
        maxTemp = roundTempDecimal(value: maxTemp)
        minTemp = roundTempDecimal(value: minTemp)
        maxminTempLabel.text = "\(maxTemp)º  /  \(minTemp)º"
        
        guard var feelLikeTemp = main?.feels_like else { return }
        feelLikeTemp = roundTempDecimal(value: feelLikeTemp)
        feelLikeLabel.text = "\(feelLikeTemp)º"
        
        localName.text = name
        
        maxminTempLabel.font = UIFont.boldSystemFont(ofSize: 20)
        localName.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    // 현재시간 요일 구하기
    private func getDayTime() {
        
        let day = getDayOfWeek(date: Date())
        
        let formatter_date = DateFormatter()
        formatter_date.dateFormat = "M월 dd일"
        let date = formatter_date.string(from: Date())
        
        dayTimeLabel.text = "\(date), \(day)요일"
        dayTimeLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    // 소수점 두 자리에서 반올림
    private func roundTempDecimal(value: Double) -> Double {
        let digit: Double = pow(10, 1) // 10의 1제곱
        let temp = round(value * digit) / digit
        return temp
    }
    
    // 요일 구하기
    private func getDayOfWeek(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEEE"
        formatter.locale = Locale(identifier:"ko_KR")
        let convertStr = formatter.string(from: date)
        return convertStr
    }
}

