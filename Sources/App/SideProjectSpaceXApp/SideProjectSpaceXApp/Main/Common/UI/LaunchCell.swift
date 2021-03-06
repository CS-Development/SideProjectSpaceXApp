//
//  LaunchCell.swift
//  SideProjectSpaceXApp
//
//  Created by Will Nixon on 9/17/21.
//

import UIKit
import SpaceXApiModule
import NetworkingService

extension Launch {
  var formattedDate: String {
    let nonFormattedDate = self.dateLocal
    let formatter = ISO8601DateFormatter()
    
    var date = ""
    if let formattedDate = formatter.date(from: nonFormattedDate) {
      let localFormatter = DateFormatter()
      
      switch self.datePrecision {
        case "quarter":
          localFormatter.dateFormat = "QQQ yyyy"
          date = localFormatter.string(from: formattedDate)
          break
        case "month":
          localFormatter.dateFormat = "MMMM yyyy"
          date = localFormatter.string(from: formattedDate)
          break
        case "day":
          localFormatter.dateFormat = "MMMM d, yyyy"
          date = localFormatter.string(from: formattedDate)
          break
        case "hour":
          localFormatter.dateFormat = "MMMM, d yyyy \u{2022} HH:mm"
          date = localFormatter.string(from: formattedDate)
          if let timeZone = formatter.timeZone.abbreviation() {
            date = date + " (\(timeZone))"
          }
          break
        default:
          break
      }
    }
    return date
  }
}

class LaunchCell: UITableViewCell {
  static let identifier = "LaunchCell"
  var service: SpaceXApiService?
  var task: HTTPClientTask?

  var launch: Launch? {
    didSet {
      launchName.text = launch?.name
      if let number = launch?.flightNumber {
        launchNumber.text = "#\(number)"
      }
      launchDate.text = launch?.formattedDate
      
      if let imageURL = launch?.smallPatch {
        if let service = service {
          task = service.downloadImage(from: imageURL) { [weak self] data in
            guard self != nil else { return }
            if let data = data, let image = UIImage(data: data) {
              DispatchQueue.main.async {
                self?.launchImageView.image = image
              }
            }
          }
        }
      }
    }
  }
  
  let launchImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.isAccessibilityElement = true
    imageView.image = UIImage(named: "spaceX")
    return imageView
  }()
  
  private let launchName: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .label
    label.font = .boldSystemFont(ofSize: 16)
    label.textAlignment = .left
    label.isAccessibilityElement = true
    return label
  }()
  
  private let launchDate: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .secondaryLabel
    label.font = .systemFont(ofSize: 16)
    label.textAlignment = .left
    label.isAccessibilityElement = true
    return label
  }()
  
  private let launchNumber: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .secondaryLabel
    label.font = .systemFont(ofSize: 16)
    label.textAlignment = .left
    label.isAccessibilityElement = true
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    // ADD VIEWS HERE
    self.addSubview(launchImageView)
    NSLayoutConstraint.activate([
      launchImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      launchImageView.heightAnchor.constraint(equalToConstant: 50),
      launchImageView.widthAnchor.constraint(equalToConstant: 50),
      launchImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
    ])
    
    self.addSubview(launchName)
    NSLayoutConstraint.activate([
      launchName.topAnchor.constraint(equalTo: launchImageView.topAnchor),
      launchName.leadingAnchor.constraint(equalTo: launchImageView.trailingAnchor, constant: 20)
    ])

    self.addSubview(launchDate)
    NSLayoutConstraint.activate([
      launchDate.bottomAnchor.constraint(equalTo: launchImageView.bottomAnchor),
      launchDate.leadingAnchor.constraint(equalTo: launchImageView.trailingAnchor, constant: 20)
    ])
    
    self.addSubview(launchNumber)
    NSLayoutConstraint.activate([
      launchNumber.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      launchNumber.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
    ])
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.launch = nil
    self.launchName.text = nil
    self.launchDate.text = nil
    self.launchNumber.text = nil
    if task != nil {
      task?.cancel()
      task = nil
    }
    self.launchImageView.image = UIImage(named: "spaceX")
  }

}
