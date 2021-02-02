import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MapPage(),
));

const double CAMERA_ZOOM = 12;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(44.745883, 65.539635);

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String googleAPIKey = "YOUR_API_KEY";
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  List<TaskModel> listofTasks = new List<TaskModel>();

  @override
  void initState() {
    super.initState();
    takePermissions();
  }

  Future<void> takePermissions() async {
    if (await Permission.location.request().isGranted &&
        await Permission.camera.request().isGranted) {
      setSourceAndDestinationIcons();
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
    ].request();
    print(statuses[Permission.camera]);
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/source.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination.png');
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SOURCE_LOCATION);
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 400,
              child: GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
                  onMapCreated: onMapCreated),
            ),
            Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listofTasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    // onTap: () => _onTapItem(),
                    title: Text(
                      listofTasks != null ? listofTasks[index].name : "",
                    ),
                    leading: Icon(
                      Icons.ac_unit_outlined,
                      color: Colors.cyan.shade900,
                    ),
                    subtitle: Text(
                      listofTasks != null ? listofTasks[index].address : "",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    setMapPins();
  }

  void setMapPins() async {
    // source pin

    TaskModel model = new TaskModel(
        "1", "Polyline 1", "", 44.711048, 65.588712, 44.718929, 65.543472);
    listofTasks.add(model);

    TaskModel model1 = new TaskModel(
        "2", "Polyline 2", "", 44.765871, 65.548230, 44.748915, 65.528095);
    listofTasks.add(model1);
    Polyline polyline;
    if (listofTasks != null && listofTasks.length > 0) {
      for (var one in listofTasks) {
        try {
          List<LatLng> polylineCoordinates = [];
          LatLng SOURCE = LatLng(one.slatitude, one.slongitude);
          LatLng DEST = LatLng(one.dlatitude, one.dlongitude);
          PolylinePoints polylinePoints = PolylinePoints();

          _markers.add(Marker(
              markerId: MarkerId('sourcePin' + one.taskid),
              position: SOURCE,
              icon: sourceIcon));
          _markers.add(Marker(
              markerId: MarkerId('destPin' + one.taskid),
              position: DEST,
              icon: destinationIcon));

          List<PointLatLng> result =
          await polylinePoints?.getRouteBetweenCoordinates(googleAPIKey,
              one.slatitude, one.slongitude, one.dlatitude, one.dlongitude);
          print("result>>>-----    " + result.toString());
          if (result.isNotEmpty) {
            print("result>>>>>>>>>>    " + result.toString());
            result.forEach((PointLatLng point) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            });
          }
          setState(() {
            polyline = Polyline(
                polylineId: PolylineId("poly" + one.taskid),
                color: Color.fromARGB(204, 147, 70, 140),
                width: 6,
                points: polylineCoordinates);
            _polylines.add(polyline);
          });
        } catch (e) {
          print("Ex--- $e");
        }
      }
    }
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}

class TaskModel {
  String taskid;
  String name;
  String address;
  double slatitude;
  double dlatitude;
  double slongitude;
  double dlongitude;

  TaskModel(this.taskid, this.name, this.address, this.slatitude,
      this.slongitude, this.dlatitude, this.dlongitude);
}
