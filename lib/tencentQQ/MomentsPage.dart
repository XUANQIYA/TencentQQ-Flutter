import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MomentsPage extends StatelessWidget {
  final mapController = MapController();
  MomentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(31.4680, 104.6796), //初始坐标
            initialZoom: 12.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?'
                  'access_token=pk.eyJ1IjoieGlhb3d1NTU1IiwiYSI6ImNtMmhrMWkyejBjbjUycW9yeHpkNWZiZGUifQ.dNjS8i7s1_Q7fN_CVw0eiw',
              userAgentPackageName: 'com.example.app',
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 80, // 放大
          child: FloatingActionButton(
            onPressed: () {
              double currentZoom = mapController.camera.zoom;
              mapController.move(mapController.camera.center, currentZoom + 1);
            },
            child: Icon(Icons.add),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16, // 定位
          child: FloatingActionButton(
            onPressed: () {
              mapController.move(LatLng(31.4680, 104.6796), 12.0);
            },
            child: Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}