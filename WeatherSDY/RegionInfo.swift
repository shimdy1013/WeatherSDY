//
//  RegionList.swift
//  WeatherSDY
//
//  Created by 심두용 on 2023/04/30.
//

import Foundation

struct RegionInfo {
    let regionID: Int
    let regionKrName: String
    let lon: Double
    let lat: Double
}

enum Region: Int {
    case seoul = 0
    case gyeonggi = 1
    case chuncheon = 2
    case gangneung = 3
    case chungju = 4
    case suwon = 5
    case andong = 6
    case daejeon = 7
    case jeonju = 8
    case daegu = 9
    case ulsan = 10
    case gwangju = 11
    case mokpo = 12
    case suncheon = 13
    case busan = 14
    case jeju = 15
    
    var regionInfo: RegionInfo {
        switch self {
        case .seoul:
            return RegionInfo(regionID: 1835847, regionKrName: "서울", lon: 127.0, lat: 37.583328)
        case .gyeonggi:
            return RegionInfo(regionID: 1841610, regionKrName: "경기", lon: 127.25, lat: 37.599998)
        case .chuncheon:
            return RegionInfo(regionID: 1845136, regionKrName: "춘천", lon: 127.734169, lat: 37.874722)
        case .gangneung:
            return RegionInfo(regionID: 1843137, regionKrName: "강릉", lon: 128.896103, lat: 37.755562)
        case .chungju:
            return RegionInfo(regionID: 1845033, regionKrName: "청주", lon: 127.93222, lat: 36.970558)
        case .suwon:
            return RegionInfo(regionID: 1846986, regionKrName: "수원", lon: 127.008888, lat: 37.291111)
        case .andong:
            return RegionInfo(regionID: 1846986, regionKrName: "안동", lon: 128.725006, lat: 36.565559)
        case .daejeon:
            return RegionInfo(regionID: 1835224, regionKrName: "대전", lon: 127.416672, lat: 36.333328)
        case .jeonju:
            return RegionInfo(regionID: 1845457, regionKrName: "전주", lon: 127.148888, lat: 35.821941)
        case .daegu:
            return RegionInfo(regionID: 1835327, regionKrName: "대구", lon: 128.550003, lat: 35.799999)
        case .ulsan:
            return RegionInfo(regionID: 1833742, regionKrName: "울산", lon: 129.266663, lat: 35.566669)
        case .gwangju:
            return RegionInfo(regionID: 1841808, regionKrName: "광주", lon: 126.916672, lat: 35.166672)
        case .mokpo:
            return RegionInfo(regionID: 1841066, regionKrName: "목포", lon: 126.388611, lat: 34.79361)
        case .suncheon:
            return RegionInfo(regionID: 1835648, regionKrName: "순천", lon: 127.489471, lat: 34.948078)
        case .busan:
            return RegionInfo(regionID: 1838519, regionKrName: "부산", lon: 129.050003, lat: 35.133331)
        case .jeju:
            return RegionInfo(regionID: 1835847, regionKrName: "제주", lon: 126.5, lat: 33.416672)
        }
    }
    
}
