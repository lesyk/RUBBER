import Cocoa
import Alamofire
import CoreLocation

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var uberTime: NSTextField!
    
    private let GOOGLE_KEY = ""
    private let UBER_KEY = ""
    private let CLIENT_ID = ""
    
    private var stops: [Stop] = []
    private var stopsAndBusses: [AnyObject] = []
    
    private var locationManager:CLLocationManager?
    private var currentLocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = NSNib(nibNamed: "MyCellView", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib!, forIdentifier: "MyCellView")
    }
    
    func getRoute(origin: String, destination: String) {
        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/directions/json", parameters: ["origin": origin, "destination": destination, "mode":"transit","alternatives":"true","key":GOOGLE_KEY])
            .responseJSON { response in
                if let json = response.result.value {
                    for route in json["routes"] as! [AnyObject] {
                        for leg in route["legs"] as! [AnyObject] {
                            for step in leg["steps"] as! [AnyObject] {
                                if step["transit_details"]! != nil {
                                    var a = Stop()
                                    a.name = step["transit_details"]!!["arrival_stop"]!!["name"] as! String
                                    
                                    if let stop = self.stops.filter({ $0.name == a.name }).first {
                                        a = stop
                                    }
                                    else {
                                        self.stops.append(a)
                                        self.stopsAndBusses.append(a)
                                    }
                                    
                                    let b = Bus()
                                    if let number = step["transit_details"]??["line"]??["short_name"] as? String {
                                        self.stopsAndBusses.append(b)
                                        b.number = number
                                        b.time = step["transit_details"]!!["arrival_time"]!!["text"] as! String
                                        a.busses.append(b)
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func getUberTime(originX: String, originY: String) {
        Alamofire.request(.GET, "https://api.uber.com/v1/estimates/time", parameters: ["start_latitude": originX, "start_longitude":originY,"server_token":UBER_KEY])
            .responseJSON { response in
                if let json = response.result.value {
                    var lowestTime = 3600
                    for route in json["times"] as! [AnyObject] {
                        if var time = route["estimate"] as? Int {
                            time = time/60
                            if lowestTime > time {
                                lowestTime = time
                                self.uberTime.stringValue = String(time)
                            }
                        }
                    }
                }
            }
    }
    
    @IBAction func getCar(sender: AnyObject) {
        if let location = currentLocation, let url = NSURL(string: "https://m.uber.com/?client_id=\(CLIENT_ID)&action=setPickup&pickup[latitude]=\(location.coordinate.latitude)&pickup[longitude]=\(location.coordinate.longitude)") {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.stopsAndBusses.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 27
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("MyCellView", owner: self) as! MyCellView
        if let item = self.stopsAndBusses[row] as? Stop {
            cell.itemName.stringValue = item.name
            cell.itemImage.hidden = false
            cell.itemDescription.stringValue = ""
        }
        else if let item = self.stopsAndBusses[row] as? Bus {
            cell.itemName.stringValue = item.number
            cell.itemDescription.stringValue = item.time
            cell.itemImage.hidden = true
        }
        cell
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 200
        self.locationManager?.delegate = self
        
        self.startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        let location: AnyObject? = (locations as NSArray).lastObject
        self.currentLocation = location as? CLLocation
        
        if let location = currentLocation {
            //        let originX = 55.666203
            //        let originY = 12.580380
            let originX = Double (location.coordinate.latitude)
            let originY = Double (location.coordinate.longitude)
            
            var margin = 0.0
            
            getUberTime(String(originX), originY: String(originY))
            
            for i in 0...10 {
                margin = Double(i)/1000
                getRoute(String(originX)+","+String(originY), destination: String(originX+margin) + "," + String(originY))
                getRoute(String(originX)+","+String(originY), destination: String(originX-margin) + "," + String(originY))
                getRoute(String(originX)+","+String(originY), destination: String(originX) + "," + String(originY+margin))
                getRoute(String(originX)+","+String(originY), destination: String(originX) + "," + String(originY-margin))
            }
        }
    }
}