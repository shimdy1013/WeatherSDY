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
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    
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
        
        guard let temp = main?.temp else { return }
        tempLabel.text = "\(temp)"
        
        guard let maxTemp = main?.temp_max else { return }
        maxTempLabel.text = "\(maxTemp)"
        
        guard let minTemp = main?.temp_min else { return }
        minTempLabel.text = "\(minTemp)"
    }
}

