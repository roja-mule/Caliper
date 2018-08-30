//
//  MeasurementsViewController.swift
//  Caliper
//
//  Created by Roja Mule on 30/08/18.
//  Copyright © 2018 GGK. All rights reserved.
//

import UIKit

class MeasurementTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
}

class MeasurementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var savedMeasurements: [Measurement] = DataManager.shared.getData() ?? []
    private let measurementReusablecell = "MeasurementTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITableViewDataSource Methods
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedMeasurements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let savedMeasurement = savedMeasurements[indexPath.row]
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeasurementTableViewCell", for: indexPath) as! MeasurementTableViewCell
        tableViewCell.name.text = savedMeasurement.name
        tableViewCell.value.text = savedMeasurement.valueIncm
        return tableViewCell
    }
}
