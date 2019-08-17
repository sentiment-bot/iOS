//
//  SenitmentReportViewController.swift
//  Sentiment Bot
//
//  Created by Moin Uddin on 1/21/19.
//  Copyright © 2019 Scott Bennett. All rights reserved.
//

import UIKit
import Charts

class SenitmentReportViewController: UIViewController, ManagerProtocol {
    
    // MARK: - Outlets
    
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    
    // MARK: - Properties
    
    var user: User?
    var teamResponses: [Response]?
    var team: Team?
    var survey: Survey?
    var teamMembers: [User]?
    
    var emojiSelection: [String] = ["😃","😊","😐","😑","😢","😞","😡"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let teamResponses = teamResponses else {
            NSLog("teamResponses wasn't set on SentimentReportViewController")
            return
        }
        createChart(teamResponses)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let themeInt = UserDefaults.standard.integer(forKey: "SelectedTheme")
        
        switch themeInt {
        case 0:
            view.backgroundColor = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
            pieChart.holeColor =  UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        case 1:
            view.backgroundColor = UIColor.white
            pieChart.holeColor = UIColor.white
        default:
            NSLog("Theme not picked")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.refreshChart()
        }
    }
    
    func createChart(_ teamResponses: [Response]) {
        for emoji in emojiSelection {
            let filteredEmojis = teamResponses.filter({ $0.emoji == emoji})
            
            let chartDataEntry = PieChartDataEntry(value: Double((Double(filteredEmojis.count)/Double(teamResponses.count))*100.0))
            chartDataEntry.label = emoji
            
            sentimentEntries.append(chartDataEntry)
        }
        
        pieChart.chartDescription?.text = ""
        
        updateChartData()
    }
    
    func refreshChart() {
        sentimentEntries.removeAll()
        APIController.shared.getTeamResponses(teamId: (team?.id)!) { (responses, errorMessage) in
            DispatchQueue.main.async {
                self.teamResponses = responses
                self.createChart(self.teamResponses!)
            }
        }
    }
    
    var sentimentEntries: [PieChartDataEntry] = []

    
    func updateChartData() {
        
        let chartDataSet = PieChartDataSet(values: sentimentEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let legend = pieChart.legend
        legend.enabled = false
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        chartData.setValueFont(.systemFont(ofSize: 18, weight: .bold))
        chartData.setValueTextColor(.lightGray)
        
        let colors = [UIColor.happy7, UIColor.happy6, UIColor.happy5, UIColor.happy4, UIColor.happy3, UIColor.happy2, UIColor.red]
        
        chartDataSet.colors = colors //as! [NSUIColor]
        
        pieChart.data = chartData
    }

}


