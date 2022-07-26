//
//  ViewController.swift
//  WeatherSDY
//
//  Created by 심두용 on 2022/07/02.
//

import UIKit
import DropDown

class ViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxminTempLabel: UILabel!
    @IBOutlet weak var feelLikeLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var regionName: UILabel!
    
    // 받아온 데이터를 저장할 프로퍼티
    var weather: Weather?
    var main: Main?
    var name: String?
    
    // DropDown 객체 생성, 리스트 정의
    let dropDown = DropDown()
    let regionList = ["Seoul", "Chuncheon", "Gangneung", "Chungju", "Suwon", "Andong", "Daejeon", "Jeonju", "Daegu", "Ulsan", "Gwangju", "Mokpo", "Suncheon", "Busan", "Jeju-do"]
    
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
        initUI()
        setDropdown()
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
        
        guard let region = name else { return }
        regionName.text = "\(region)"
        
        maxminTempLabel.font = UIFont.boldSystemFont(ofSize: 20)
        regionName.font = UIFont.boldSystemFont(ofSize: 24)
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
    
    // DropDown UI 커스텀
    func initUI() {
        // DropDown View의 배경
        dropView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        dropView.layer.cornerRadius = 8
        
        DropDown.appearance().textColor = UIColor.black // 아이템 텍스트 색상
        DropDown.appearance().selectedTextColor = UIColor.red // 선택된 아이템 텍스트 색상
        DropDown.appearance().backgroundColor = UIColor.white // 아이템 팝업 배경 색상
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray // 선택한 아이템 배경 색상
        DropDown.appearance().setupCornerRadius(8)
        dropDown.dismissMode = .automatic // 팝업을 닫을 모드 설정
    }
    
    func setDropdown() {
        // dataSource로 ItemList를 연결
        dropDown.dataSource = regionList
        
        // anchorView를 통해 UI와 연결
        dropDown.anchorView = self.dropView
        
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropDown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        
        // Item 선택 시 처리
        dropDown.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            self!.regionName.text = item
        }
        
        // 취소 시 처리

    }

    // View 클릭 시 Action
    @IBAction func dropdownClicked(_ sender: Any) {
        dropDown.show() // 아이템 팝업을 보여준다.
    }
}

