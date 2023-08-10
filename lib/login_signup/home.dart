import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:driver/widgets/MainButton.dart';
import 'package:driver/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/Size_of_screen.dart';
import 'package:driver/userProvider.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart' ;
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget with OSMMixinObserver{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

  @override
  Future<void> mapIsReady(bool isReady) {
    if (isReady) {
      Future.delayed(const Duration(seconds: 1), () async {
       // await mapController.currentLocation();
      });

    }
    throw UnimplementedError();
  }
}

class _HomePageState extends State<HomePage> with OSMMixinObserver {

  CustomerProvider? customerProvider;
  double latitude = 5;
  double longitude = -1;
  var mapController = MapController.withUserPosition(
trackUserLocation:  const UserTrackingOption(
  enableTracking: true,
  unFollowUser: false,
),

    //areaLimit: BoundingBox.
  );


  bool connect=true;
   late StreamSubscription<ConnectivityResult> subscription;

  Stream<bool> connectCheck() {
     subscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
       bool isDeviceConnected = await InternetConnectionChecker().hasConnection;
       if(isDeviceConnected==true){
         setState(() {
           connect=true;
         });

       }
       else{
         setState(() {
           connect=false;
         });
       }
       // print("hello$isDeviceConnected");

      }
      else{
        setState(() {
          connect=false;
        });
      }


    });
     print(connect);
    return Stream.value(connect);
  }

   GlobalKey<ScaffoldState> scaffoldKey=GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    connectCheck();
    customerProvider = context.read<CustomerProvider>();
    mapController.addObserver(this);
    //onSingleTap(GeoPoint(latitude: 5, longitude: -1));
  }

  @override
  Future<void> mapIsReady(bool isReady) {
    // TODO: implement mapIsReady
    throw UnimplementedError();
  }
  @override
  dispose() {
    subscription.cancel();
    mapController.dispose();
    super.dispose();
  }
  @override
  Future<void> onSingleTap(GeoPoint position) async {
    //super.onLongTap(position);
    super.onSingleTap(GeoPoint(latitude: 5, longitude: -1));
    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        setState(() {
          latitude = mapController.listenerMapSingleTapping.value!.latitude;
          longitude = mapController.listenerMapSingleTapping.value!.longitude;
        });
        // mapController.drawRoad(
        //     GeoPoint(latitude: latitude, longitude: longitude),
        //     GeoPoint(latitude: latitude+1.2, longitude: longitude+0.2),
        //     //roadOption:
        // );

             }
    });
    showMap(latitude, longitude);
  // mapController.setMarkerIcon(point, icon)
    print(mapController.listenerMapSingleTapping.value?.latitude);
    // ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(
    //         "Location: ${mapController.listenerMapSingleTapping.value}")));

    /// TODO
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldKey,
      drawer: const Drawers(),
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const
            Icon(Icons.power_settings_new,
                color: Colors.red),

           // tooltip: 'Search for a specific food',
            onPressed: () {
              //Navigator.pushNamed(context, "specificBuyItem");
            },
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations
                  .of(context)
                  .openAppDrawerTooltip,
            );
          },
        ),
      ),
      floatingActionButton:!connect?null:
          FloatingActionButton(
            onPressed: () {
              mapController.myLocation();

            },
            child: const Icon(Icons.my_location),
          ),


      body: SizedBox(
          width: double.infinity,
          //color: const Color.fromRGBO(245, 245, 245, 0.9),
          // padding: const EdgeInsets.all(10),
          child:StreamBuilder<bool>(
            stream: connectCheck(),
            builder:
                (BuildContext context, AsyncSnapshot<bool> snapshot)
            {
              if(snapshot.data==false){
                return  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You are offline",
                        style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("Go on online in order to start getting"
                        " delivery \nrequest from customers and vendors"),
                    const SizedBox(height: 20),
                    MainButton(
                      onPressed: () {
                         connectCheck();
                         },
                      color: Colors.green,
                      backgroundColor: Colors.green,
                      child: const Text("Refresh"),
                    )
                  ],
                );
              }
              else{
                mapController.addObserver(this);
                return OSMFlutter(
                  //mapIsLoading:const CircularProgressIndicator(),
                  controller: mapController,
                  userTrackingOption: const UserTrackingOption(
                    enableTracking: true,
                    unFollowUser: false,
                  ),
                  //isPicker: true,
                  initZoom: 17,
                  minZoomLevel: 2,
                  maxZoomLevel: 18,
                  stepZoom: 1.0,
                  userLocationMarker: UserLocationMaker(
                    personMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.location_history_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    directionArrowMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.motorcycle,
                        size: 48,
                      ),
                    ),
                  ),
                  roadConfiguration: const RoadOption(
                    roadColor: Colors.black,
                  ),
                  markerOption: MarkerOption(
                      defaultMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 56,
                        ),
                      )
                  ),
                );
              }
            },),

      )

      );

  }

  Future<void> showMap(double lat, double long) async{
    showModalBottomSheet(
      //backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        context: scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const Text("Accept New Delivery?", style: TextStyle(
                              fontSize: 16
                          )),
                          const SizedBox(height: 40),
                          SecondaryButton(
                            text: "Accept",
                            onPressed: () {
                              Navigator.pop(context);
                              personToDeliverTo(lat, long);
                            },
                            color: Colors.green,
                            backgroundColor: Colors.green,),
                          const SizedBox(height: 5),
                          SecondaryButton(
                            text: "Reject",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.white,
                            backgroundColor: Colors.white,)
                        ]
                    )
                );
              }
          );
        });
  }

  Future<void> personToDeliverTo(double lat, double long) async{
    showModalBottomSheet(
      //backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                    height: 150,
                  margin: const EdgeInsets.all(10),
                  padding:  const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)),
                    child:Column(
                        children: [
                          const SizedBox(height: 10),
                          const Text("Deliver to Jerry Boateng", style: TextStyle(
                              fontSize: 16
                          )),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              MainButton(
                                onPressed: () {},
                                color: Colors.green,
                                backgroundColor: Colors.green,
                                child:const Text("Complete Delivery"),),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 50,
                                child: MainButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "chat");
                                  },
                                  color: Colors.white,
                                  backgroundColor: Colors.white,
                                  child:const Text("Message"),),
                              )
                            ],
                          ),

                        ]
                    )
                );
              });
        });
  }
}
