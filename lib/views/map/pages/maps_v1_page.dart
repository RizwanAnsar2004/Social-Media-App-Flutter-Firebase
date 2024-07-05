import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moneyup/views/map/map_type_google.dart';
import 'package:moneyup/views/map/data_dummy.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../components/bottom_navigation_bar.dart';

class MapsV1Page extends StatefulWidget {
  const MapsV1Page({Key? key}) : super(key: key);

  @override
  _MapsV1PageState createState() => _MapsV1PageState();
}

class _MapsV1PageState extends State<MapsV1Page> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late Map<String, dynamic> userData = {};

  double? latitude;
  double? longitude;
  var mapType = MapType.normal;
  Position? _currentPosition;
  BitmapDescriptor? _customIcon;
  bool _mapVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return userSnapshot;
  }

  Future<void> someFunction() async {
    var userSnapshot = await getUserDetails();
    setState(() {
      userData = userSnapshot.data() as Map<String, dynamic>;
    }); // Assign the user data to userData
  }

  Future<void> _loadCustomMarkerIcon() async {
    final Uint8List markerIcon = await _downloadImage(
        'https://images.unsplash.com/photo-1575936123452-b67c3203c357?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D');
    setState(() {
      _customIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  Future<Uint8List> _downloadImage(String url) async {
    var cacheManager = DefaultCacheManager();
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      // Download image if not in cache
      fileInfo = await cacheManager.downloadFile(url);
    }
    return fileInfo.file.readAsBytes();
  }

  List<String> _getFollowingIds(String currentUserId) {
    List<dynamic> followingData = userData['following'] ?? [];
    List<String> followingIds = followingData.cast<String>();
    print("there you go");
    print(followingIds);
    return followingIds;
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLocation(double long, double lat) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('location').doc(user.uid).set({
        'uid': user.uid,
        'markerId': userData['username'],
        'pfp': userData['photoUrl'],
        'long': long,
        'lat': lat,
        'datePublished': DateTime.now(),
      });

      print('Location added successfully');
    } catch (err) {
      print('Failed to add location: $err');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    someFunction();
    printfollowings();
    _loadAllUserLocations();
  }

  void printfollowings() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> followingIDs = _getFollowingIds(currentUserId);
    if (followingIDs.isNotEmpty) {
      print(followingIDs);
    } else {
      print("List empty");
    }
  }

  void setCurrentLocation() {
    setState(() {
      latitude = _currentPosition?.latitude;
      longitude = _currentPosition?.longitude;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentPosition = null;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentPosition = null;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        latitude = _currentPosition?.latitude;
        longitude = _currentPosition?.longitude;
      });

      if (latitude != null && longitude != null) {
        await addLocation(longitude!, latitude!);
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> _loadAllUserLocations() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('location').get();
      Set<Marker> newMarkers = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return Marker(
          markerId: MarkerId(data['markerId']),
          position: LatLng(data['lat'], data['long']),
          infoWindow: InfoWindow(title: data['markerId']),
          icon: _customIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toSet();

      setState(() {
        markers = newMarkers;
      });
      _zoomToFitAllMarkers();

      print("user locations:");

      print(markers);
    } catch (e) {
      print('Error loading user locations: $e');
    }
  }

  Future<void> _zoomToFitAllMarkers() async {
    if (markers.isEmpty) return;

    GoogleMapController controller = await _controller.future;

    LatLngBounds bounds = _calculateBounds(markers);
    CameraUpdate update = CameraUpdate.newLatLngBounds(bounds, 50);

    controller.animateCamera(update);
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double southWestLat = markers.first.position.latitude;
    double southWestLng = markers.first.position.longitude;
    double northEastLat = markers.first.position.latitude;
    double northEastLng = markers.first.position.longitude;

    markers.forEach((marker) {
      if (marker.position.latitude < southWestLat) {
        southWestLat = marker.position.latitude;
      }
      if (marker.position.longitude < southWestLng) {
        southWestLng = marker.position.longitude;
      }
      if (marker.position.latitude > northEastLat) {
        northEastLat = marker.position.latitude;
      }
      if (marker.position.longitude > northEastLng) {
        northEastLng = marker.position.longitude;
      }
    });

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    String user = FirebaseAuth.instance.currentUser!.uid;
    List<String> followings = _getFollowingIds(user);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ghost Mode",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Switch(
              value: _mapVisible,
              activeTrackColor: Color.fromARGB(255, 109, 222, 81),
              onChanged: (value) {
                setState(() {
                  _mapVisible = value;
                  if (_mapVisible) {
                    _loadAllUserLocations(); // Reload markers when map is visible
                    _zoomToFitAllMarkers(); // Fit all markers on the screen
                  }
                });
              },
            ),
          ],
        ),
      ),
      body:
          //  _mapVisible
          //     ?
          _currentPosition == null
              ? Center(
                  child: Text(
                    'Location service is disabled. Please enable it.\nOR\nDisable Ghost Mode\nThen Reload it',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Stack(
                  children: [
                    // GOOGLE MAPS
                    _buildGoogleMaps(),
                  ],
                ),
      // : Center(
      //     child: Text(
      //       'Ghost Mode is On',
      //       textAlign: TextAlign.center,
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildGoogleMaps() {
    if (latitude == null || longitude == null) {
      return Center(child: CircularProgressIndicator());
    }
    Marker currentLocationMarker = Marker(
      markerId: MarkerId("currentLocation"),
      position: LatLng(latitude!, longitude!), // Use the current location
      infoWindow: InfoWindow(title: "Current Location"),
      icon: _customIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    Set<Marker> updatedmarkers;
    if (_mapVisible) {
      updatedmarkers = {currentLocationMarker, ...markers};
    } else {
      updatedmarkers = {};
    }

    print(updatedmarkers);
    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude!, longitude!),
        zoom: 17,
      ),
      markers: updatedmarkers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _zoomToFitAllMarkers();
        if (_mapVisible) {
          _zoomToFitAllMarkers(); // Fit all markers on the screen
        }
      },
    );
  }

  void onSelectedMapType(Type value) {
    setState(() {
      switch (value) {
        case Type.Normal:
          mapType = MapType.normal;
          break;
        case Type.Hybrid:
          mapType = MapType.hybrid;
          break;
        case Type.Terrain:
          mapType = MapType.terrain;
          break;
        case Type.Satellite:
          mapType = MapType.satellite;
          break;
        default:
      }
    });
  }

  List<Widget> stars() {
    List<Widget> list1 = [];
    for (var i = 0; i < 5; i++) {
      list1.add(const Icon(
        Icons.star,
        color: Colors.orange,
        size: 15,
      ));
    }
    return list1;
  }
}
