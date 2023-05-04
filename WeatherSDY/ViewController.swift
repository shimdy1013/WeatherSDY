//
//  ViewController.swift
//  WeatherSDY
//
//  Created by 심두용 on 2022/07/02.
//

import UIKit
import DropDown

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxminTempLabel: UILabel!
    @IBOutlet weak var feelLabel: UILabel!
    @IBOutlet weak var feelLikeLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var regionName: UILabel!
    @IBOutlet weak var hourlyBackgroundView: UIView!
    @IBOutlet weak var hourlyUI: UIStackView!
    
    @IBOutlet weak var hourlyView: UIView!
    
    // 받아온 데이터를 저장할 프로퍼티
    var weather: Weather?
    var main: Main?
    var name: String?
    var hourly: Hourly?
    var oneWeaather: OneWeather?
    
    // DropDown 객체 생성, 리스트 정의
    let dropDown = DropDown()
    let regionKrList = ["서울", "경기", "춘천", "강릉", "청주", "수원", "안동", "대전", "전주", "대구", "울산", "광주", "목포", "순천", "부산", "제주"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hourlyBackgroundView 테두리
        hourlyBackgroundView.layer.cornerRadius = 20
        hourlyBackgroundView.layer.borderWidth = 1.0
        hourlyBackgroundView.layer.borderColor = UIColor.white.cgColor
        feelLabel.text = "체감온도"
        
        // UserDefaults
        let userDefaults = UserDefaults.standard
        if let selectedRegion = userDefaults.object(forKey: "selectedRegion") {
            guard let region = Region(rawValue: selectedRegion as! Int) else { return }
            let regionInfo = region.regionInfo
            getWeather(regionInfo: regionInfo)
        } else {
            getWeather()
        }
        initUI()
        setDropdown()
    }
    
    private func getWeather(regionInfo: RegionInfo = Region.seoul.regionInfo) {
    
        // data fetch
        WeatherService().getCurrentWeather(regionID: regionInfo.regionID) { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.weather = weatherResponse.weather.first
                    self.main = weatherResponse.main
                    self.name = regionInfo.regionKrName // weatherResponse.name
                    self.setWeatherUI()
                    self.getDayTime()
                }
            case .failure(_ ):
                print("GetCurrentWeather Error")
            }
        }
        OnecallWeatherService().getOnecallWeather(lon: regionInfo.lon, lat: regionInfo.lat) { result in
            switch result {
            case .success(let oneWeatherResponse):
                DispatchQueue.main.async {
                    for i in 0...17 {
                        self.hourly = oneWeatherResponse.hourly[i+1]
                        self.setHourlyWeatherUI(num: i)
                    }
                }
            case .failure(_ ):
                print("GetOnecallWeather Error")
            }
        }
    }
    
    private func setWeatherUI() {
        // 현재 날씨
        // let url = URL(string: "https://openweathermap.org/img/wn/\(self.weather?.icon ?? "00")@2x.png")
        // let data = try? Data(contentsOf: url!)
        // if let data = data {
        //    iconImageView.image = UIImage(data: data)
        // }

        switch self.weather?.icon {
        case "01d":
            iconImageView.image = UIImage(named: "contrast")
        case "01n":
            iconImageView.image = UIImage(named: "moon")
        case "02d":
            iconImageView.image = UIImage(named: "cloudDay")
        case "02n":
            iconImageView.image = UIImage(named: "cloudNight")
        case "03d", "03n", "04d", "04n":
            iconImageView.image = UIImage(named: "cloud")
        case "09d", "09n", "10d", "10n":
            iconImageView.image = UIImage(named: "rain")
        case "11d", "11n":
            iconImageView.image = UIImage(named: "thunderstorm")
        case "13d", "13n":
            iconImageView.image = UIImage(named: "snow")
        case "50d", "50n":
            iconImageView.image = UIImage(named: "haze")
        default:
            iconImageView.image = UIImage(named: "contrast")
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
    
    private func setHourlyWeatherUI(num: Int) {
        
        // hourly - 시간 구하기
        guard let dt: Int = hourly?.dt else { return }
        let beforeTime = TimeInterval(dt)
        let hourlyDate = Date(timeIntervalSince1970: beforeTime) // beforeTime: Double만 정상 작동
        // print(hourlyDate) // 2022-08-04 06:00:00 +0000
        let formatter_hourly = DateFormatter()
        formatter_hourly.dateFormat = "a h시"
        let hourlyTime = formatter_hourly.string(from: hourlyDate)
        //  print(hourlyTime) // 오후 2시
        
        // 시간 UI 적용
        let hourlyTimeView: UIView = hourlyUI.arrangedSubviews[num].subviews[0]
        if let hourlyTimeLabel = hourlyTimeView as? UILabel {   // UIView를 UILabel로 다운캐스팅
            hourlyTimeLabel.text = hourlyTime
            hourlyTimeLabel.font = UIFont.systemFont(ofSize: 15)
        } else {
            print("hourlyUI fail")
        }
        
        // 아이콘 UI 적용 - 너무 느려서 아이콘 변경
        //let url = URL(string: "https://openweathermap.org/img/wn/\(hourly?.weather.first?.icon ?? "00")@2x.png")
        //let data = try? Data(contentsOf: url!)
        //let hourlyIconView: UIView = hourlyUI.arrangedSubviews[num].subviews[1]
        //guard let hourlyIcon = hourlyIconView as? UIImageView else { return }
        //guard let data = data else { return }
        //hourlyIcon.image = UIImage(data: data)
        let hourlyIconView: UIView = hourlyUI.arrangedSubviews[num].subviews[1]
        guard let hourlyIcon = hourlyIconView as? UIImageView else { return }
        
        switch hourly?.weather.first?.icon {
        case "01d":
            hourlyIcon.image = UIImage(named: "contrast")
        case "01n":
            hourlyIcon.image = UIImage(named: "moon")
        case "02d":
            hourlyIcon.image = UIImage(named: "cloudDay")
        case "02n":
            hourlyIcon.image = UIImage(named: "cloudNight")
        case "03d", "03n", "04d", "04n":
            hourlyIcon.image = UIImage(named: "cloud")
        case "09d", "09n", "10d", "10n":
            hourlyIcon.image = UIImage(named: "rain")
        case "11d", "11n":
            hourlyIcon.image = UIImage(named: "thunderstorm")
        case "13d", "13n":
            hourlyIcon.image = UIImage(named: "snow")
        case "50d", "50n":
            hourlyIcon.image = UIImage(named: "haze")
        default:
            hourlyIcon.image = UIImage(named: "contrast")
        }
        
        // 온도 UI 적용
        guard let hourlyTemp = hourly?.temp else { return }
        let hourlyTempView: UIView = hourlyUI.arrangedSubviews[num].subviews[2]
        guard let hourlyTempLabel = hourlyTempView as? UILabel else { return }
        hourlyTempLabel.text = "\(roundTempDecimalOne(value: hourlyTemp))º"
        
        // 강수 UI 적용
        guard let pop = hourly?.pop else { return }
        let hourlyPopView: UIView = hourlyUI.arrangedSubviews[num].subviews[3]
        guard let hourlyPopLabel = hourlyPopView as? UILabel else { return }
        let popText = Int(pop * 100)
        hourlyPopLabel.text = "\(popText)%"
        let hourlyPopImage: UIImageView  = hourlyUI.arrangedSubviews[num].subviews[4] as! UIImageView
        hourlyPopImage.image = UIImage(named: "pop")
    }
    
    
    // 현재시간 요일 구하기, UI 적용
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
    
    // 소수점 한 자리에서 반올림
    private func roundTempDecimalOne(value: Double) -> Int {
        let digit: Double = pow(10, 0) // 10의 0제곱
        let temp = Int(round(value * digit) / digit)
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
        dropDown.dataSource = regionKrList
        
        // anchorView를 통해 UI와 연결
        dropDown.anchorView = self.dropView
        
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropDown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        
        // Item 선택 시 처리
        dropDown.selectionAction = { [weak self] (index, item) in
            
            var regionList = Region.seoul
            
            switch item {
            case "서울":
                regionList = .seoul
            case "경기":
                regionList = .gyeonggi
            case "춘천":
                regionList = .chuncheon
            case "강릉":
                regionList = .gangneung
            case "청주":
                regionList = .chungju
            case "수원":
                regionList = .suwon
            case "안동":
                regionList = .andong
            case "대전":
                regionList = .daejeon
            case "전주":
                regionList = .jeonju
            case "대구":
                regionList = .daegu
            case "울산":
                regionList = .ulsan
            case "광주":
                regionList = .gwangju
            case "목포":
                regionList = .mokpo
            case "순천":
                regionList = .suncheon
            case "부산":
                regionList = .busan
            case "제주":
                regionList = .jeju
            default:
                regionList = .seoul
            }
            
            UserDefaults.standard.set(regionList.rawValue, forKey: "selectedRegion")
            let regionInfo = regionList.regionInfo
            self?.getWeather(regionInfo: regionInfo)

            //선택한 Item을 TextField에 넣어준다.
            self!.regionName.text = item
        }
        
        // 취소 시 처리
    }

    // DropDown 클릭 시 Action
    @IBAction func dropdownClicked(_ sender: Any) {
        dropDown.show() // 아이템 팝업을 보여준다.
    }
}

