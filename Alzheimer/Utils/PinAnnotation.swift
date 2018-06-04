import MapKit

class PinAnnotation:  NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(title : String, substitlel : String , coordinatel : CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = substitlel
        self.coordinate = coordinatel
    }
    
}
