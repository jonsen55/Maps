import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // var _myLocation;
  // final _amarsingh = LatLng(28.2110, 83.9844); // Amarsingh Chowk
  // final _prithvi = LatLng(28.21035, 83.98358); // Sabhagriha Chowk
  // final _sabhagriha = LatLng(28.2102, 83.9846); // Sabhagriha Chowk
  // final _buddha = LatLng(28.20680, 83.99510); //Buddha Chowk

  // final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;

  List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    _initalizeLocation(); 
  }

  Future<void> _initalizeLocation() async{
    if(!await _checkRequestPermission()) return;
  // listen for location updates and update the current location
    _location.onLocationChanged.listen((LocationData locationData) {
      if(locationData.latitude != null && locationData.longitude != null){
        
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        isLoading = false; // stop the loading once the location is obtained.
      });
      }
    });
  }

  // Method to fetch coordinates for a given location using the Open Street Map Nominatim API.
  Future<void> _fetchCoordinates(String location) async{
    final url = Uri.parse("https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    final response = await http.get(url, headers: {
      'User-Agent': 'Maps_App (jonsengaire544@gmail.com)',
      'Accept': 'application/json'
    });
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      if(data.isNotEmpty){
        // Extract latitude and longitude from the API response
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await _fetchRoute();
      }else{
        errorMessage("Location not found.");
      }
    }else{
      errorMessage("Failed to fetch location. Try again later");
    }
  }

  // Method to fetch the route between the current location and the destination using OSRM API.
  Future<void> _fetchRoute() async{
    if(_currentLocation == null || _destination == null) return;
    final url = Uri.parse("http://router.project-osrm.org/route/v1/driving/"'${_currentLocation!.longitude},${_currentLocation!.latitude};''${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline');
    final response = await http.get(url);

    if(response.statusCode  == 200){
      final data = jsonDecode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
      _bottomSheetShow(_currentLocation!, _destination!);
      

    }else{
      errorMessage('Failed to fetch route. Try again later.');
    }
  }

  String formatDistance(double distanceInMeters) {
    double distanceInKM;
    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(2)} m";
    } else {
      distanceInKM = distanceInMeters / 1000;
      return "${distanceInKM.toStringAsFixed(2)} km";
    }
  }

  Future<void> _bottomSheetShow(LatLng _currentLocation, LatLng _destination) async{
    String formatedDistance;
    double calculatedDistance = await _calculateDistance(_currentLocation, _destination);
      if(calculatedDistance > 0){
        formatedDistance = formatDistance(calculatedDistance);
        Scaffold.of(context).showBottomSheet(
          backgroundColor: Colors.blue,
          (context) => Container(
            height: 200,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
              children: [
                Text('Vehicles', style: TextStyle(fontWeight: FontWeight.w500),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.bike_scooter_outlined,
                        color: Colors.white,
                        size: 40,
                      ), 
                    ),SizedBox(height: 12,),
                    Text("Motorbike",style: TextStyle(fontWeight: FontWeight.w500),),
                      ],
                    ),

//                     Card(
//   elevation: 4,
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   child: Padding(
//     padding: const EdgeInsets.all(16.0),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircleAvatar(
//           radius: 60,
//           backgroundImage: AssetImage('assets/images/rider_image.jpg'), // Use NetworkImage if from URL
//           backgroundColor: Colors.blue,
//           child: Icon(
//             Icons.bike_scooter_outlined,
//             color: Colors.white,
//             size: 40,
//           ),
//         ),
//         SizedBox(height: 12),
//         Text(
//           "Rider Name",
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
//         ),
//         SizedBox(height: 8),
//         Text(
//           "\$Price",
//           style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
//         ),
//         SizedBox(height: 8),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.star, color: Colors.amber, size: 16),
//             SizedBox(width: 4),
//             Text(
//               "Rating",
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ],
//     ),
//   ),
// )

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.car_rental_outlined,
                        color: Colors.white,
                        size: 40,
                      ), 
                    ),SizedBox(height: 12,),
                    Text("Car",style: TextStyle(fontWeight: FontWeight.w500),),
                      ],
                    ),
                    
                  ],
                ),
              ],
            )),
          ),
        );
      }else{
        errorMessage("Failed to calculate distance. Try again later.");
      }
  }

  Future<double> _calculateDistance(LatLng _currentLocation, LatLng _destination) async{
    if(_currentLocation != null && _destination != null){
      double distanceInMeters = await distance2point(GeoPoint(longitude: _currentLocation.longitude,latitude: _currentLocation.latitude,),GeoPoint( longitude: _destination.longitude, latitude: _destination.latitude, ),);
      return distanceInMeters;
    }
    return 0;
  }

  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);


    setState(() {
      _route = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();
    });
  }
  Future<bool> _checkRequestPermission() async{
    bool serviceEnabled = await _location.serviceEnabled();
    if(!serviceEnabled){
      serviceEnabled = await _location.requestService();
      if(!serviceEnabled) return false; 
    }
    
      PermissionStatus permissionGranted = await _location.hasPermission();
      if(permissionGranted == PermissionStatus.denied){
        permissionGranted = await _location.requestPermission();
        if(permissionGranted != PermissionStatus.granted){
          return false;
        }
      }
      return true;
  }



  Future<void> _userCurrentLocation() async{
    if(_currentLocation != null){
      /// _mapController not compatible with OSMFlutter
      // _mapController.move(_currentLocation!, 14);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Current Location not available."))
      );
    }
  }

  // method to display an error message using a snackbar
  void errorMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 700,
        child: Stack(
          children: [
            isLoading ? Center(child: CircularProgressIndicator()):
            FlutterMap(
              /// Not compatible with OSMFlutter
              // mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? const LatLng(0,0),
                initialZoom: 13
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.yourapp',
                ),
                CurrentLocationLayer(
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.white,
                      ),
                    ),
                    markerSize: Size(35, 35),
                    markerDirection: MarkerDirection.top
        
                  ),
                ),
                if(_destination != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _destination!, 
                      width: 50,
                      height: 50,
                      child: Icon(Icons.location_pin, color: Colors.red,))
                    ],
                  ),
                  if(_currentLocation != null && _destination != null && _route.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: _route, strokeWidth: 5, color: Colors.blue)
                  ])
                
            ],),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter a location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    )
                  ),
                  IconButton(onPressed: (){
                    final location = _searchController.text.trim();
                    if(location.isNotEmpty){
                      _fetchCoordinates(location);
                    }
                  }, icon: Icon(Icons.search, color: Colors.blueGrey,),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  )

                  ],
                ),
              )
            
            )
          ],
          
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _userCurrentLocation,
      backgroundColor: Colors.blue,
      child: Icon(Icons.my_location, color: Colors.white,),
      ),





      // SingleChildScrollView(
      //   child: Column(
      //     children: 
      //     [
      //       SizedBox(
      //         height: 80,
      //         child: Center(
      //           child: Padding(
      //             padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      //             child: TextFormField(
      //               decoration: InputDecoration(
      //                 border: OutlineInputBorder(
      //                   borderRadius: BorderRadius.all(Radius.circular(30)),
      //                 ),
      //                 labelText: 'Search',
      //                 suffixIcon: Icon(Icons.search),
                        
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     SizedBox(
      //       height: 500,
      //     child: 
      //     FlutterMap(
      //     options: MapOptions(
      //       center: LatLng(28.190615, 83.993257),
      //       zoom: 15.0,
      //       // maxZoom: 50
      //     ),
      //     children: [
      //       TileLayer(
      //         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      //         subdomains: ['a', 'b', 'c'],
      //         userAgentPackageName: 'com.example.yourapp',
      //       ),
      //       PolylineLayer(
      //         polylines: [
      //           Polyline(
      //             points: [
      //               _amarsingh,
      //               _prithvi,
      //               _sabhagriha,
      //               _buddha
      //             ],
      //             color: Colors.blue,
      //             strokeWidth: 4.0,
      //           ),
              
      //       ]),
      //       MarkerLayer(
      //         markers: [
      //           Marker(
      //             width: 80.0,
      //             height: 80.0,
      //             point: LatLng(28.190615, 83.993257),
      //             builder: (ctx) => const Icon(Icons.location_pin, color: Color.fromARGB(255, 215, 55, 44), size: 40),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
        
          
      //   ),
      //     ]
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(onPressed: (){
      //   _myLocation = LatLng(28.190615, 83.993257);
      //   setState(() {
      //    // update location to my location
      //    // change the center of the map to my location
      //   });
      // },
      // backgroundColor: Colors.blueAccent,
      // foregroundColor: Colors.white,
      // child: Icon(Icons.my_location),),
    );
  }

}

