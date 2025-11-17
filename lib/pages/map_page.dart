import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var _myLocation;
  final _amarsingh = LatLng(28.2110, 83.9844); // Amarsingh Chowk
  final _prithvi = LatLng(28.21035, 83.98358); // Sabhagriha Chowk
  final _sabhagriha = LatLng(28.2102, 83.9846); // Sabhagriha Chowk
  final _buddha = LatLng(28.20680, 83.99510); //Buddha Chowk
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: 
          [
            SizedBox(
              height: 80,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      labelText: 'Search',
                      suffixIcon: Icon(Icons.search),
                        
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 500,
          child: 
          FlutterMap(
          options: MapOptions(
            center: LatLng(28.190615, 83.993257),
            zoom: 15.0,
            // maxZoom: 50
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.yourapp',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    _amarsingh,
                    _prithvi,
                    _sabhagriha,
                    _buddha
                  ],
                  color: Colors.blue,
                  strokeWidth: 4.0,
                ),
              
            ]),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(28.190615, 83.993257),
                  builder: (ctx) => const Icon(Icons.location_pin, color: Color.fromARGB(255, 215, 55, 44), size: 40),
                ),
              ],
            ),
          ],
        ),
        
          
        ),
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _myLocation = LatLng(28.190615, 83.993257);
        setState(() {
         // update location to my location
         // change the center of the map to my location
        });
      },
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      child: Icon(Icons.my_location),),
    );
  }

}