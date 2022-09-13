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
    let regionList = ["서울", "경기", "춘천", "강릉", "청주", "수원", "안동", "대전", "전주", "대구", "울산", "광주", "목포", "순천", "부산", "제주"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hourlyBackgroundView 테두리
        hourlyBackgroundView.layer.cornerRadius = 20
        hourlyBackgroundView.layer.borderWidth = 1.0
        hourlyBackgroundView.layer.borderColor = UIColor.white.cgColor
        // data fetch
        WeatherService().getCurrentWeather { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.weather = weatherResponse.weather.first
                    self.main = weatherResponse.main
                    self.name = "서울" // weatherResponse.name
                    self.setWeatherUI()
                    self.getDayTime()
                }
            case .failure(_ ):
                print("error")
            }
        }
        OnecallWeatherService().getOnecallWeather { result in
            switch result {
            case .success(let oneWeatherResponse):
                DispatchQueue.main.async {
                    for i in 0...17 {
                        self.hourly = oneWeatherResponse.hourly[i+1]
                        self.setHourlyWeatherUI(num: i)
                    }
                }
            case .failure(_ ):
                print("onecall error")
            }
        }
        initUI()
        setDropdown()
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
        dropDown.dataSource = regionList
        
        // anchorView를 통해 UI와 연결
        dropDown.anchorView = self.dropView
        
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropDown.bottomOffset = CGPoint(x: 0, y: dropView.bounds.height)
        
        // Item 선택 시 처리
        dropDown.selectionAction = { [weak self] (index, item) in
            var regionID: Int = 1835847
            var regionKrName: String = "서울"
            var lon: Double = 127.0
            var lat: Double = 37.583328
            
            switch item {
            case "서울":
                regionID = 1835847
                regionKrName = "서울"
                lon = 127.0
                lat = 37.583328
            case "경기":
                regionID = 1841610
                regionKrName = "경기"
                lon = 127.25
                lat = 37.599998
            case "춘천":
                regionID = 1845136
                regionKrName = "춘천"
                lon = 127.734169
                lat = 37.874722
            case "강릉":
                regionID = 1843137
                regionKrName = "강릉"
                lon = 128.896103
                lat = 37.755562
            case "청주":
                regionID = 1845033
                regionKrName = "청주"
                lon = 127.93222
                lat = 36.970558
            case "수원":
                regionID = 1835553
                regionKrName = "수원"
                lon = 127.008888
                lat = 37.291111
            case "안동":
                regionID = 1846986
                regionKrName = "안동"
                lon = 128.725006
                lat = 36.565559
            case "대전":
                regionID = 1835224
                regionKrName = "대전"
                lon = 127.416672
                lat = 36.333328
            case "전주":
                regionID = 1845457
                regionKrName = "전주"
                lon = 127.148888
                lat = 35.821941
            case "대구":
                regionID = 1835327
                regionKrName = "대구"
                lon = 128.550003
                lat = 35.799999
            case "울산":
                regionID = 1833742
                regionKrName = "울산"
                lon = 129.266663
                lat = 35.566669
            case "광주":
                regionID = 1841808
                regionKrName = "광주"
                lon = 126.916672
                lat = 35.166672
            case "목포":
                regionID = 1841066
                regionKrName = "목포"
                lon = 126.388611
                lat = 34.79361
            case "순천":
                regionID = 1835648
                regionKrName = "순천"
                lon = 127.489471
                lat = 34.948078
            case "부산":
                regionID = 1838519
                regionKrName = "부산"
                lon = 129.050003
                lat = 35.133331
            case "제주":
                regionID = 1846265
                regionKrName = "제주"
                lon = 126.5
                lat = 33.416672
            default:
                regionID = 1835847
                regionKrName = "서울"
                lon = 127.0
                lat = 37.583328
            }
            
                
            // data fetch
            WeatherService().getCurrentWeather(regionID:regionID) { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self?.weather = weatherResponse.weather.first
                        self?.main = weatherResponse.main
                        self?.name = regionKrName
                        self?.setWeatherUI()
                        self?.getDayTime()
                    }
                case .failure(_ ):
                    print("error")
                }
            }
            
            OnecallWeatherService().getOnecallWeather(lon: lon, lat: lat) { result in
                switch result {
                case .success(let oneWeatherResponse):
                    DispatchQueue.main.async {
                        for i in 0...17 {
                            self?.hourly = oneWeatherResponse.hourly[i+1]
                            self?.setHourlyWeatherUI(num: i)
                        }
                    }
                case .failure(_ ):
                    print("onecall error")
                }
            }
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

